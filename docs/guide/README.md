# 介绍

## 安装

Sentry 通过在应用程序的运行时中使用 SDK 捕获数据。

使用 Go Modules 时，无需安装任何软件即可开始将 Sentry 与 Go 程序一起使用。 导入 SDK，然后当您下次构建程序时，`go` tool 会自动下载最新版本的 SDK。

```go
import (
	"github.com/getsentry/sentry-go"
)
```

不使用或没有 Go Modules 时，要使用最新版本的SDK，请运行：

```sh
go get github.com/getsentry/sentry-go
```

有关如何管理依赖项的更多信息，[请参阅有关 Modules 的 Go 文档](https://github.com/golang/go/wiki/Modules#how-to-upgrade-and-downgrade-dependencies)。

## 配置

配置应在应用程序的生命周期中尽早进行。

```go
package main

import (
	"log"
	"time"

	"github.com/getsentry/sentry-go"
)

func main() {
	err := sentry.Init(sentry.ClientOptions{
    // 在此处设置您的 DSN 或设置 SENTRY_DSN 环境变量。
		Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
    // 可以在这里设置 environment 和 release，
    // 也可以设置 SENTRY_ENVIRONMENT 和 SENTRY_RELEASE 环境变量。
		Environment: "",
		Release:     "",
    // 允许打印 SDK 调试消息。
    // 入门或尝试解决某事时很有用。
		Debug: true,
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
	}
  // 在程序终止之前刷新缓冲事件。
  // 将超时设置为程序能够等待的最大持续时间。
	defer sentry.Flush(2 * time.Second)
}
```

## 验证

此代码段包含一个故意的错误，因此您可以在设置后立即测试一切是否正常：

```go
package main

import (
	"log"
	"time"

	"github.com/getsentry/sentry-go"
)

func main() {
	err := sentry.Init(sentry.ClientOptions{
		Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
	})
	if err != nil {
		log.Fatalf("sentry.Init: %s", err)
	}
	defer sentry.Flush(2 * time.Second)

	sentry.CaptureMessage("It works!")
}
```

要查看和解决记录的错误，请登录 [sentry.io](https://sentry.io/welcome/)(或者你私有部署的 sentry) 并打开您的项目。 单击错误标题将打开一个页面，您可以在其中查看详细信息并将其标记为已解决。