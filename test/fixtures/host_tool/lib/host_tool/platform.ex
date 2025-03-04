defmodule HostTool.Platform do
  @moduledoc false
  @behaviour Nerves.Artifact.BuildRunner
  @behaviour Nerves.Package.Platform

  alias Nerves.Artifact

  @impl Nerves.Package.Platform
  def bootstrap(pkg) do
    path = System.get_env("PATH")
    System.put_env("PATH", "#{Nerves.Artifact.Cache.get(pkg)}:#{path}")
    :ok
  end

  @impl Nerves.Artifact.BuildRunner
  def build(pkg, _toolchain, _opts) do
    build_path = Artifact.build_path(pkg)
    File.rm_rf(build_path)

    priv_dir =
      pkg.path
      |> Path.join("priv")
      |> Path.expand()

    build_path
    |> Path.dirname()
    |> File.mkdir_p!()

    File.mkdir_p!(priv_dir)

    File.ln_s!(priv_dir, build_path)

    Nerves.Port.cmd("make", [])

    {:ok, build_path}
  end

  @impl Nerves.Package.Platform
  def build_path_link(pkg) do
    Artifact.build_path(pkg)
  end

  @impl Nerves.Artifact.BuildRunner
  def archive(pkg, _toolchain, _opts) do
    build_path = Artifact.build_path(pkg)
    name = Artifact.download_name(pkg) <> Artifact.ext(pkg)
    Nerves.Utils.File.tar(build_path, name)
    {:ok, Path.join(File.cwd!(), name)}
  end

  @impl Nerves.Artifact.BuildRunner
  def clean(pkg) do
    build_path = Artifact.build_path(pkg)
    File.rm_rf(build_path)

    priv_dir =
      pkg.path
      |> Path.join("priv")
      |> Path.expand()

    File.rm_rf(priv_dir)
    :ok
  end
end
