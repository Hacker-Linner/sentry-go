# 识别用户

用户包含一些关键信息，这些信息构成了 Sentry 中的唯一身份。每个选项都是可选的，但必须存在一个选项才能使 Sentry SDK 捕获用户：

`id`

您的用户内部标识符。

`username`

用户名。通常用作比内部ID更好的标签。

`email`

用户名的替代（或添加）。Sentry 知道电子邮件地址，并且可以显示 Gravatars 之类的内容并解锁消息传递功能。

`ip_address`

用户的IP地址。如果用户未经身份验证，Sentry 将 IP 地址用作用户的唯一标识符。Sentry 将尝试从 HTTP 请求数据中提取此信息（如果有）。

识别用户：

```go
sentry.ConfigureScope(func(scope *sentry.Scope) {
	scope.SetUser(sentry.User{Email: "jane.doe@example.com"})
})
```

可以将其他 key/value 对指定为元数据，Sentry SDK会将这些键/值对与用户一起存储。
