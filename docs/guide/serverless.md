# Serverless

## Source Context

`sentry-go` SDK 附带了对 Serverless 解决方案的支持。但是，为了正确使用源上下文，您需要将源代码与二进制文件本身捆绑在一起。

例如，当使用 **AWS Lambda** 并给出这个树结构时:

```bash
.
├── bin
│   └── upload-image
│   └── process-image
│   └── create-thumbnails
├── functions
│   └── upload-image
│       └── main.go
│   └── process-image
│       └── main.go
│   └── create-thumbnails
│       └── main.go
├── helper
│   ├── foo.go
│   └── bar.go
├── util
│   ├── baz.go
│   └── qux.go
```

您可以使用以下命令构建二进制文件之一并将其与必要的源文件捆绑在一起：

```bash
GOOS=linux go build -o bin/upload-image functions/upload-image/main.go && zip -r handler.zip bin/upload-image functions/upload-image/ helper/ util/
```

唯一的要求是您在已部署的计算机上找到源代码。 SDK 会自动完成其他所有操作。

## Events Delivery

大多数（如果不是全部）无服务器解决方案在关闭进程之前不会等待网络响应。因此，我们需要确保将事件传递给 Sentry 的服务器。

可以使用 `sentry.Flush` 方法或通过将传输交换到 `HTTPSyncTransport` 来实现双重目的。