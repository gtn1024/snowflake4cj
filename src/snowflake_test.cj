package snowflake4cj

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import std.sync.*

@Test
func testSnowflake() {
    let snowflake = Snowflake(0, 0)
    var last = 0
    for (i in 0..10000) {
        let new = snowflake.nextId()
        @Expect(new > last)
        last = new
    }
}

@Test
func testFailedWhenMachineIdIsInvalid() {
    for (i in -1..50) {
        for (j in -1..50) {
            if (i < 0 || i > 31 || j < 0 || j > 31) {
                @ExpectThrows[IllegalArgumentException]({
                    Snowflake(i, j)
                })
            } else {
                let snowflake = Snowflake(i, j)
                let id = snowflake.nextId()
                @Expect(id > 0)
            }
        }
    }
}

@Test
func testSynchronized() {
    let snowflake = Snowflake(0, 0)
    let threads = 50
    let count = 10000

    let mtx = ReentrantMutex()
    let list = ArrayList<Int64>()

    let sc = SyncCounter(threads)

    for (_ in 0..threads) {
        spawn {
            for (_ in 0..count) {
                synchronized (mtx) {
                    list.append(snowflake.nextId())
                }
            }
            sc.dec()
        }
    }

    sc.waitUntilZero()

    @Expect(threads * count, list.size)

    for (i in 1..list.size) {
        @Expect(list[i - 1] < list[i])
    }

    let set = HashSet<Int64>(list)
    @Expect(threads * count, set.size)
}
