# http_request

**Table of Contents**

1. [Description](#description)
1. [Requirements](#requirements)
1. [Parameters](#parameters)
1. [Usage](#usage)
    - [Making a request](#making-a-request)
    - [Adding headers](#adding-headers)
    - [Adding a body](#adding-a-body)

## Description

This module includes a task for making HTTP and HTTPS requests.

## Requirements

This task requires Ruby to be installed on the target it runs on.

## Parameters

### `base_url`

**REQUIRED.** The fully qualified URL scheme to make requests to.

- **Type:** `String[1]`

### `body`

The request body.

- **Type:** `Optional[String]`

### `cacert`

An absolute path to the CA certificate.

- **Type:** `Optional[String[1]]`

### `cert`

An absolute path to the client certificate.

- **Type:** `Optional[String[1]]`

### `follow_redirects`

If `true`, automatically follows redirects.

- **Type:** `Boolean`
- **Default:** `true`

### `headers`

A map of headers to add to the payload.

- **Type:** `Optional[Hash[String, String]]`

### `key`

An absolute path to the RSA keypair.

- **Type:** `Optional[String[1]]`

### `max_redirects`

The maximum number of redirects to follow when `follow_redirects` is `true`.

- **Type:** `Integer[1]`
- **Default:** `20`

### `method`

The HTTP method to use.

- **Type:** `Enum[delete, get, post, put]`
- **Default:** `get`

### `path`

The path to append to the `base_url`.

- **Type:** `Optional[String[1]]`

## Usage

The only required parameter for the `http_request` task is `url`, which is the
fully qualified URL scheme to make a request to. By default, the task will make
a GET request.

### Making a request

The simplest usage of this task is to make a GET request by only setting the
`url` parameter:

- **Unix-like shell command**

  ```shell
  $ bolt task run http_request --targets localhost base_url=http://httpbin.org/get
  ```

- **PowerShell command**

  ```powershell
  > Invoke-BoltTask -Name 'http_request' -Targets 'localhost' base_url=http://httpbin.org/get
  ```

- **Plan step**

  ```yaml
  parameters:
    targets:
      type: TargetSpec

  steps:
    - name: request
      task: http_request
      targets: $targets
      parameters:
        base_url: 'http://httpbin.org/get'

  return: $request
  ```

### Adding headers

You can send custom headers as part of a request using the `headers` parameter.
This parameter accepts a map of header names to values.

To add headers to a request from the command line, pass the headers as JSON to
the `headers` parameter:

- **Unix-like shell command**

  ```shell
  $ bolt task run http_request --targets localhost base_url=http://httpbin.org/get headers='{"Content-Type":"application/json"}'
  ```

- **PowerShell command**

  ```powershell
  > Invoke-BoltTask -Name 'http_request' -Targets 'localhost' base_url=http://httpbin.org/get headers='{"Content-Type":"application/json"}'
  ```

- **Plan step**

  ```yaml
  parameters:
    targets:
      type: TargetSpec

  steps:
    - name: request
      task: http_request
      targets: $targets
      parameters:
        base_url: 'http://httpbin.org/get'
        headers:
          Content-Type: application/json

  return: $request
  ```

### Adding a body

You can add a body to the request using the `body` parameter. This parameter
accepts a string value. If you need to send data in a specific format, such
as JSON, you should format the data before running the task.

To send a body in the request from the command line, pass the data to the
`body` parameter:

- **Unix-like shell command**

  ```shell
  $ bolt task run http_request --targets localhost base_url=http://httpbin.org/post method=post body=hello
  ```

- **PowerShell command**

  ```powershell
  > Invoke-BoltTask -Name 'http_request' -Targets 'localhost' base_url=http://httpbin.org/post method=post body=hello
  ```

- **Plan step**

  ```yaml
  parameters:
    targets:
      type: TargetSpec

  steps:
    - name: request
      task: http_request
      targets: $targets
      parameters:
        base_url: 'http://httpbin.org/post'
        method: post
        body: hello

  return: $request
  ```