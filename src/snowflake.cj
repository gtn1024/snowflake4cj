package snowflake4cj

import std.time.{DateTime}
import std.sync.{ReentrantMutex}

public class Snowflake {
    let twepoch: Int64 = 1725148800000
    let workerIdBits: Int64 = 5
    let datacenterIdBits: Int64 = 5
    let maxWorkerId: Int64 = -1 ^ (-1 << workerIdBits)
    let maxDatacenterId: Int64 = -1 ^ (-1 << datacenterIdBits)
    let sequenceBits: Int64 = 12
    let workerIdShift: Int64 = sequenceBits
    let datacenterIdShift: Int64 = sequenceBits + workerIdBits
    let timestampLeftShift: Int64 = sequenceBits + workerIdBits + datacenterIdBits
    let sequenceMask: Int64 = -1 ^ (-1 << sequenceBits)

    let workerId: Int64
    let datacenterId: Int64
    var sequence: Int64 = 0
    var lastTimestamp: Int64 = -1

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

    func tilNextMillis(lastTimestamp: Int64) {
        var timestamp = timeGen()

        while (timestamp <= lastTimestamp) {
            timestamp = timeGen()
        }

        timestamp
    }

    func timeGen() {
        DateTime.nowUTC().toUnixTimeStamp().toMilliseconds()
    }
}
