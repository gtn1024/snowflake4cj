<div align="center">
  <h1>snowflake4cj</h1>
  <p>Snowflake algorithm for Cangjie</p>
</div>
<p align="center">
  <img alt="" src="https://img.shields.io/badge/release-v1.1.0-brightgreen" style="display: inline-block;" />
  <img alt="" src="https://img.shields.io/badge/cjc-v0.55.3-brightgreen" style="display: inline-block;" />
  <img alt="" src="https://github.com/gtn1024/snowflake4cj/actions/workflows/ci.yml/badge.svg" style="display: inline-block;" />
</p>

## 介绍 / Introduction

snowflake4cj 是一个基于 Cangjie 的雪花算法实现。

snowflake4cj is a snowflake algorithm implementation based on Cangjie.

## 安装 / Installation

```toml
# In the `dependencies` section of `cjpm.toml`
snowflake4cj = { git = "https://github.com/gtn1024/snowflake4cj.git", tag = "1.1.0" }
```

## 使用 / Usage

```cj
import snowflake4cj.Snowflake

main(): Int64 {
    let snowflake = Snowflake(0, 0)
    for (i in 0..1000) {
        let id = snowflake.nextId()
        println(id)
    }
    return 0
}
```

## QQ 群

欢迎加入 [仓颉交流群（非官方）：985038695](https://qm.qq.com/q/PcRbAUJSo0)

![qqgroup](./.github/qqgroup.jpg)
