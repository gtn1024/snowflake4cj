package snowflake4cj

import std.time.{DateTime}
import std.sync.{ReentrantMutex}

public open class Snowflake {
    internal let twepoch: Int64 = 1725148800000
    internal let workerIdBits: Int64 = 5
    internal let datacenterIdBits: Int64 = 5
    internal let maxWorkerId: Int64 = -1 ^ (-1 << workerIdBits)
    internal let maxDatacenterId: Int64 = -1 ^ (-1 << datacenterIdBits)
    internal let sequenceBits: Int64 = 12
    internal let workerIdShift: Int64 = sequenceBits
    internal let datacenterIdShift: Int64 = sequenceBits + workerIdBits
    internal let timestampLeftShift: Int64 = sequenceBits + workerIdBits + datacenterIdBits
    internal let sequenceMask: Int64 = -1 ^ (-1 << sequenceBits)

    internal let workerId: Int64
    internal let datacenterId: Int64
    internal var sequence: Int64 = 0
    internal var lastTimestamp: Int64 = -1

    public init(workerId: Int64, datacenterId: Int64) {
        if (workerId > maxWorkerId || workerId < 0) {
            throw IllegalArgumentException("workerId can't be greater than ${maxWorkerId} or less than 0")
        }

        if (datacenterId > maxDatacenterId || datacenterId < 0) {
            throw IllegalArgumentException("datacenterId can't be greater than ${maxWorkerId} or less than 0")
        }

        this.workerId = workerId
        this.datacenterId = datacenterId
    }

    let mtx = ReentrantMutex()

    public func nextId() {
        synchronized (mtx) {
            var timestamp = timeGen()

            if (timestamp < lastTimestamp) {
                throw IllegalStateException("Clock moved backwards. Refusing to generate id for ${lastTimestamp - timestamp} milliseconds")
            }

            if (lastTimestamp == timestamp) {
                sequence = (sequence + 1) & sequenceMask

                if (sequence == 0) {
                    timestamp = tilNextMillis(lastTimestamp)
                }
            } else {
                sequence = 0
            }

            lastTimestamp = timestamp

            ((timestamp - twepoch) << timestampLeftShift) | (datacenterId << datacenterIdShift) | (workerId << workerIdShift) | sequence
        }
    }

    internal func tilNextMillis(lastTimestamp: Int64) {
        var timestamp = timeGen()

        while (timestamp <= lastTimestamp) {
            timestamp = timeGen()
        }

        timestamp
    }

    internal func timeGen() {
        DateTime.nowUTC().toUnixTimeStamp().toMilliseconds()
    }
}
