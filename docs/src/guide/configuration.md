# 配置项

* 基本选项

详细了解如何配置 SDK。 这些选项是在首次初始化 SDK 时设置的，并作为对象传递给 `init()`。

* Releases & Health

了解如何配置您的 SDK 以告知 Sentry 您的版本。

* Transports

通过 Transports，您可以更改将事件传递到 Sentry 的方式。

* Environments

了解如何配置您的 SDK，以告知 Sentry 您的环境。

* 过滤和采样事件

详细了解如何配置您的 SDK 以过滤和采样报告给 Sentry 的事件。

* Shutdown and Draining

如果应用程序意外关闭，请详细了解我们的 SDK 的默认行为。


## 基本选项

可以使用多种选项对 SDK 进行配置。这些选项在很大程度上在 SDK 中进行了标准化，但是为了更好地适应平台特性，还存在一些差异。选项在 SDK 首次初始化时设置。

选项作为一个 `sentry.ClientOptions` 的实例传递给 `Init()` 方法：

```go
sentry.Init(sentry.ClientOptions{
	Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
	Debug: true,
})
```

```go
// ClientOptions 用来配置 SDK 客户端
type ClientOptions struct {
  // 要使用的 DSN。如果未设置 DSN，则实际上将禁用客户端。
	Dsn string
  // 在调试模式下，调试信息会打印到 stdout，以帮助您了解 sentry 在做什么。
	Debug bool
  // 配置 SDK 是否应生成堆栈跟踪并将其附加到纯捕获消息调用。
	AttachStacktrace bool
  // 事件提交的采样率（0.0-1.0，默认为 1.0）
	SampleRate float64
  // 用于与事件消息进行匹配的正则表达式字符串列表，如果适用，
  // 则捕获错误类型和值。如果找到匹配项，则将删除整个事件。
	IgnoreErrors []string
  // 发送回调之前。
	BeforeSend func(event *Event, hint *EventHint) *Event
  // 在面包屑之前添加回调。
	BeforeBreadcrumb func(breadcrumb *Breadcrumb, hint *BreadcrumbHint) *Breadcrumb
  // 要在当前客户端上安装的集成，接收默认集成
	Integrations func([]Integration) []Integration
  // io.Writer 实现应与 `Debug` 模式一起使用
	DebugWriter io.Writer
  // transport 使用
  // 这是实现 `Transport` 接口的结构的一个实例。
  // 默认来自 `transport.go` 的 `httpTransport`
	Transport Transport
  // The server name to be reported.
  // 要报告的服务器名称。
	ServerName string
  // 与事件一起发送的版本。
	Release string
  // 与事件一起发送的 dist。
	Dist string
  // 与事件一起发送的环境。
	Environment string
  // 面包屑的最大数量。
	MaxBreadcrumbs int
  // 指向 `http.Client` 的可选指针，它将与默认的 HTTPTransport 一起使用。
  // 使用您自己的客户端将忽略 HTTPTransport，HTTPProxy，HTTPSProxy 和 CaCerts 选项。
	HTTPClient *http.Client
  // 指向 `http.Transport` 的可选指针，它将与默认的 HTTPTransport 一起使用。
  // 使用您自己的 transport 将使 HTTPProxy，HTTPSProxy 和 CaCerts 选项被忽略。
	HTTPTransport *http.Transport
  // 要使用的可选 HTTP 代理。
  // 这将默认为 `http_proxy` 环境变量。
  // 或 `https_proxy`（如果存在的话）。
	HTTPProxy string
  // 要使用的可选 HTTPS 代理。
  // 这将默认为 `HTTPS_PROXY` 环境变量
  // 或 `http_proxy`（如果存在的话）。
	HTTPSProxy string
  // 要使用的可选 CaCert。
  // 默认为 `gocertifi.CACerts()`。
	CaCerts *x509.CertPool
}
```

### 提供 SSL 证书

默认情况下，TLS 使用主机的根 CA 设置。 如果您没有 `ca-certificates`（这应该是解决丢失证书问题的首选方法），
而要使用 `gocertifi`，则可以提供预加载的证书文件作为 `sentry.Init` 调用的选项之一：

```go
package main

import (
	"log"

	"github.com/certifi/gocertifi"
	"github.com/getsentry/sentry-go"
)

sentryClientOptions := sentry.ClientOptions{
	Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
}

rootCAs, err := gocertifi.CACerts()
if err != nil {
	log.Println("Could not load CA Certificates: %v\n", err)
} else {
	sentryClientOptions.CaCerts = rootCAs
}

sentry.Init(sentryClientOptions)
```

### 删除默认集成

`sentry-go` SDK 几乎没有内置的集成，这些集成可以使用其他信息增强事件或以一种或另一种方式管理事件。

如果您想了解更多有关它们的信息，请直接查看[源代码](https://github.com/getsentry/sentry-go/blob/master/integrations.go)。

但是，在某些情况下，您可能需要禁用其中一些功能。为此，您可以使用 `Integrations` 配置选项并过滤不需要的集成。 例如：

```go
sentry.Init(sentry.ClientOptions{
	Integrations: func(integrations []sentry.Integration) []sentry.Integration {
		var filteredIntegrations []sentry.Integration
		for _, integration := range integrations {
			if integration.Name() == "ContextifyFrames" {
				continue
			}
			filteredIntegrations = append(filteredIntegrations, integration)
		}
		return filteredIntegrations
	},
})
```

## Releases & Health

发行版是部署到环境中的代码版本。当您向 Sentry 提供有关发行版的信息时，您可以：

* 确定新版本中引入的问题和回归
* 预测哪个提交引起了问题，谁可能负责
* 通过在提交消息中包含问题编号来解决问题
* 部署代码后接收电子邮件通知


### 绑定版本

配置客户端 SDK 时，请包含发行 ID（通常称为“版本”）。该 ID 通常是 git SHA 或自定义版本号。

发行版名称不能：

* 包含换行符或空格
* 使用正斜杠（“/”），反斜杠（“\”），句点（“.”）或双句号（“..”）
* 超过200个字符

每个组织的版本都是全球性的;在它们前面加上特定项目的前缀，以便于区分。

```go
sentry.Init(sentry.ClientOptions{
    Release: "my-project-name@2.3.12",
})
```

如何使版本对代码可用由您决定。例如，您可以使用在构建过程中设置的环境变量。

这将用发布值标记每个事件。我们建议您在部署 Sentry 之前告诉它一个新版本，因为这将解锁更多的特性，如我们的文档中所讨论的。
但如果不这样做，Sentry 将在第一次看到带有该 release ID 的事件时自动在系统中创建一个 release 实体。

配置了 SDK 之后，您可以安装存储库集成，或者手动为 Sentry 提供您自己的提交元数据。
请阅读我们关于[版本](https://docs.sentry.io/product/releases/)的文档，
以获得关于集成、关联提交以及在部署版本时告知 Sentry 的更多信息。


## Transports

通过 Transports，您可以更改将事件传递到 Sentry 的方式。

Sentry Go SDK 本身提供了两个内置传输。`HTTPTransport`，它是非阻塞的，默认情况下使用。
和 `HTTPSyncTransport` 处于阻塞状态。每种传输方式都提供略有不同的配置选项。

### 用法

要配置传输，请提供一个 `sentry.Transport` 实例到 `ClientOptions`

```go
package main

import (
	"time"

	"github.com/getsentry/sentry-go"
)

func main() {
	sentrySyncTransport := sentry.NewHTTPSyncTransport()
	sentrySyncTransport.Timeout = time.Second * 3

	sentry.Init(sentry.ClientOptions{
		Dsn: "https://examplePublicKey@o0.ingest.sentry.io/0",
		Transport: sentrySyncTransport,
	})
}
```

每种运输方式都提供自己的工厂函数。`NewHTTPTransport` 和 `NewHTTPSyncTransport`。

### 选项

### HTTPTransport

```go
// HTTPTransport 是由 `Client` 使用的 `Transport` 接口的默认实现。
type HTTPTransport struct {
  // 传输缓冲区的大小。默认为30。
	BufferSize int
  // HTTP 客户端请求超时。默认为30秒。
	Timeout time.Duration
}
```

### HTTPSyncTransport

```go
// HTTPSyncTransport 是 `Transport` 接口的实现，它在每个捕获的事件之后都会阻塞。
type HTTPSyncTransport struct {
  // HTTP 客户端请求超时。默认为30秒。
	Timeout time.Duration
}
```

## Environments

Sentry 在收到带有环境标签的事件时自动创建环境。环境是区分大小写的。
环境名称不能包含换行、空格或斜杠，不能是字符串“None”，或超过64个字符。您不能删除环境，但可以[隐藏](https://docs.sentry.io/platforms/go/configuration/environments/)它们。

```go
sentry.Init(sentry.ClientOptions{
	Environment: "production",
})
```

在 sentry.io 的问题详细信息页面中，环境帮助您更好地过滤问题、版本和用户反馈。您可以在我们的文档中了解更多[关于使用环境的信息](https://docs.sentry.io/product/sentry-basics/environments/)。

## 过滤和采样事件

将 Sentry 添加到您的应用程序将为您提供有关错误和性能的大量非常有价值的信息，而这些信息是您以前无法获得的。而且很多信息都是好的-只要是正确的信息，而且数量合理。

Sentry SDK 有几个配置选项来帮助您控制这一点，允许您过滤掉您不想要的事件，并从您想要的事件中选取一个代表性的示例。

**注意**： Sentry UI 还提供了使用[入站筛选器](https://docs.sentry.io/product/error-monitoring/filtering/)筛选事件的方法。
不过，我们建议您在客户端级别进行过滤，因为它可以消除发送您实际上不需要的事件的开销。

### 过滤错误事件

配置您的 SDK，通过使用 `beforeSend` 回调方法并配置、启用或禁用集成来过滤错误事件。

**Using** `beforeSend`

所有的 Sentry SDK 都支持 `beforeSend` 回调方法。
`beforeSend` 在事件被发送到服务器之前被立即调用，因此它是您可以编辑其数据的最终位置。
它将事件对象作为参数接收，因此您可以使用该参数根据定制逻辑和事件上可用的数据修改事件数据或完全删除它(通过返回 `null`)。

在 Go 中，函数可以用来修改事件或返回一个全新的事件。如果返回 `nil`, SDK 将丢弃该事件。

```go
sentry.Init(sentry.ClientOptions{
	BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
		// Modify the event here
		event.User.Email = "" // Don't send user's email address
		return event
	},
})
```

还要注意，可以过滤面包屑，这在[面包屑文档中](https://docs.sentry.io/product/error-monitoring/breadcrumbs/)已经讨论过了。

### Event Hints

`before-send` 回调同时传递 `event` 和第二个参数 `hint`，它包含一个或多个 hint。

通常，一个 `hint` 保存原始异常，以便可以提取其他数据或影响分组。在本例中，如果捕获到某种类型的异常，则指纹被强制设置为公共值:

```go
sentry.Init(sentry.ClientOptions{
	BeforeSend: func(event *sentry.Event, hint *sentry.EventHint) *sentry.Event {
		if ex, ok := hint.OriginalException.(DatabaseConnectionError); ok {
			event.Fingerprint = []string{"database-connection-error"}
		}

		return event
	},
})
```

有关可用提示的信息，请参见[EventHint实现](https://github.com/getsentry/sentry-go/blob/master/interfaces.go)。

当 SDK 为传输创建一个事件或breadcrumb时，该传输通常是从某种源对象创建的。
例如，错误事件通常是由日志记录或异常实例创建的。
为了更好地定制，SDK 将这些对象发送到特定的回调(`beforeSend`、`beforeBreadcrumb` 或 SDK 中的事件处理器系统)。

### 使用 Hints

有两个地方提供 Hints：
1. `beforeSend / beforeBreadcrumb`
2. `eventProcessors`

事件和 breadcrumb `hints` 是包含各种用于组合事件或 breadcrumb 的信息的对象。通常， `hints` 保存原始异常，以便可以提取其他数据或影响分组。

用于事件，如 `event_id`、`originalException`、`syntheticException`(内部用于生成更干净的堆栈跟踪)，以及附加的任何其他任意 `data`。

对于面包屑，`hints` 的使用依赖于实现。对于 XHR 请求，hint 包含 XHR 对象本身;对于用户交互，hint 包含 DOM 元素和事件名等等。

在本例中，如果捕获到某种类型的异常，则指纹被强制设置为公共值：

::: tip
您选择的平台或 SDK 要么不支持此功能，要么文档中缺少此功能。

如果你认为这是一个错误，请在[GitHub上告诉我们](https://github.com/getsentry/sentry-docs/issues/new)。
:::

### Hints for Events

`originalException`

引起 Sentry SDK 创建事件的原始异常。这对于更改 Sentry SDK 分组事件的方式或提取其他信息很有用。

`syntheticException`

当引发字符串或非错误对象时，Sentry 会创建一个合成异常，这样您就可以获得一个基本的堆栈跟踪。这个异常被存储在这里以供进一步的数据提取。

### Hints for Breadcrumbs

`event`

对于从浏览器事件创建的 breadcrumb, Sentry SDK 通常将事件作为 hint 提供给 breadcrumb。
例如，这可以用于从目标 DOM 元素提取数据到 breadcrumb。

`level / input`

对于从控制台日志截取创建的面包屑。这将保留原始控制台日志级别和日志功能的原始输入数据。

`response / input`

用于从 HTTP 请求创建的面包屑。它保存响应对象(来自 fetch API )和 fetch 函数的输入参数。

`request / response / event`

用于从 HTTP 请求创建的面包屑。它包含请求和响应对象(来自节点 HTTP API )以及节点事件( `response` 或 `error` )。

`xhr`

对于通过旧版 `XMLHttpRequest` API 通过 HTTP 请求创建的面包屑。这将保留原始的 xhr 对象。

::: tip
您选择的平台或 SDK 要么不支持此功能，要么文档中缺少此功能。

如果你认为这是一个错误，请在[GitHub上告诉我们](https://github.com/getsentry/sentry-docs/issues/new)。
:::

### 采样错误事件

要向 Sentry 发送一个具有代表性的错误样本，
请将 SDK 配置中的 `SampleRate` 选项设置为`0`(发送了 0% 的错误)和`1`(发送了 100% 的错误)之间的数字。
这是一个静态速率，它同样适用于所有错误。例如，对 25% 的错误进行抽样：

::: tip
您选择的平台或 SDK 要么不支持此功能，要么文档中缺少此功能。

如果你认为这是一个错误，请在[GitHub上告诉我们](https://github.com/getsentry/sentry-docs/issues/new)。
:::

**注意**：误差采样率不是动态的;更改它需要重新部署。此外，设置SDK示例速率会限制对事件源的可见性。为您的项目设置速率限制(仅在容量大时降低事件)可能更适合您的需要。

## Shutdown and Draining

大多数 SDK 的默认行为是在后台通过网络异步发送事件。这意味着如果应用程序意外关闭，可能会丢失一些事件。 SDK 提供了处理这种情况的机制。

为避免程序终止时意外删除事件，请安排 `sentry.Flush` 进行调用，通常使用 `defer`。

如果您使用多个客户端，请安排每个相应的客户端刷新。

`Flush` 会一直等到任何缓冲事件发送到 Sentry 服务器，直到最多阻塞给定的超时时间。如果超时，则返回 `false`。 在这种情况下，某些事件可能尚未发送。

```go
func main() {
	// err := sentry.Init(...)
	defer sentry.Flush(2 * time.Second)

	sentry.CaptureMessage("my message")
}
```