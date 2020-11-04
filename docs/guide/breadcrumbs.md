# 面包屑

Sentry 使用面包屑创建事件发生之前的事件线索。这些事件与传统日志非常相似，但是可以记录更丰富的结构化数据。

此页面概述了手动面包屑记录和自定义。
了解有关“Issue Details”页面上显示的更多信息，
以及如何过滤面包屑以快速解决问题。

:::tip 了解 SDK 使用情况

想要修改面包屑界面的开发人员可以使用专用于[面包屑界面](https://develop.sentry.dev/sdk/event-payloads/breadcrumbs/)的开发人员文档详细了解此内容。
:::

## 手动面包屑

每当发生有趣的事情时，您都可以手动添加面包屑。
例如，如果用户通过身份验证或发生其他状态更改，则可以手动记录面包屑。

```go
sentry.AddBreadcrumb(&sentry.Breadcrumb{
	Category: "auth",
	Message: "Authenticated user " + user.email,
	Level: sentry.LevelInfo,
});
```

## 自动面包屑

SDK 及其相关的集成将自动记录许多类型的面包屑。
例如，浏览器 JavaScript SDK 将自动记录所有位置更改。

## 定制面包屑

SDK 允许您通过 `before_breadcrumb` hook 自定义面包屑。
此 hook 传递了已经组装好的面包屑，并且在某些SDK中传递了可选提示。
该函数可以修改面包屑，或通过返回 `null` 来决定完全放弃它：

```go
sentry.Init(sentry.ClientOptions{
	BeforeBreadcrumb: func(breadcrumb *sentry.Breadcrumb, hint *sentry.BreadcrumbHint) *sentry.Breadcrumb {
		if breadcrumb.Category == "auth" {
			return nil
		}
		return breadcrumb
	},
})
```