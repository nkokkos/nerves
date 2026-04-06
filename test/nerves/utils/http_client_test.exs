# SPDX-FileCopyrightText: 2018 Justin Schneck
# SPDX-FileCopyrightText: 2022 Frank Hunleth
# SPDX-FileCopyrightText: 2023 Jon Carstens
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Nerves.Utils.HTTPClientTest do
  use NervesTest.Case

  alias Nerves.Utils.HTTPClient

  setup do
    _ = :inets.start(:httpc, profile: :nerves)

    on_exit(fn ->
      # Stop the httpc profile to clear proxy settings that persist
      # and would otherwise poison the :nerves profile for resolver tests
      _ = :inets.stop(:httpc, :nerves)
      System.delete_env("HTTP_PROXY")
      System.delete_env("HTTPS_PROXY")
    end)
  end

  test "proxy config returns no credentials when no proxy supplied" do
    assert HTTPClient.proxy_request_options("http://nerves-project.org") == []
    assert HTTPClient.proxy_httpc_options() == []
  end

  test "proxy config returns http_proxy credentials when supplied" do
    System.put_env("HTTP_PROXY", "http://nerves:test@example.com")

    assert HTTPClient.proxy_request_options("http://nerves-project.org") == [
             proxy_auth: {~c"nerves", ~c"test"}
           ]

    assert HTTPClient.proxy_httpc_options() == [{:proxy, {{~c"example.com", 80}, []}}]
  end

  test "proxy config returns http_proxy credentials when only username supplied" do
    System.put_env("HTTP_PROXY", "http://nopass@example.com")

    assert HTTPClient.proxy_request_options("http://nerves-project.org") == [
             proxy_auth: {~c"nopass", ~c""}
           ]

    assert HTTPClient.proxy_httpc_options() == [{:proxy, {{~c"example.com", 80}, []}}]
  end

  test "proxy config returns credentials when the protocol is https" do
    System.put_env("HTTPS_PROXY", "https://test:nerves@example.com")

    assert HTTPClient.proxy_request_options("https://nerves-project.org") == [
             proxy_auth: {~c"test", ~c"nerves"}
           ]

    assert HTTPClient.proxy_httpc_options() == [{:https_proxy, {{~c"example.com", 443}, []}}]
  end

  test "proxy config returns empty list when no credentials supplied" do
    System.put_env("HTTP_PROXY", "http://example.com:123")
    assert HTTPClient.proxy_request_options("http://nerves-project.org") == []
    assert HTTPClient.proxy_httpc_options() == [{:proxy, {{~c"example.com", 123}, []}}]
  end

  test "proxy config returns both http and https" do
    System.put_env("HTTP_PROXY", "http://test:nerves@http_proxy.com")
    System.put_env("HTTPS_PROXY", "https://test:nerves@https_proxy.com")

    assert HTTPClient.proxy_httpc_options() == [
             {:proxy, {{~c"http_proxy.com", 80}, []}},
             {:https_proxy, {{~c"https_proxy.com", 443}, []}}
           ]
  end
end
