# SPDX-FileCopyrightText: 2018 Justin Schneck
# SPDX-FileCopyrightText: 2023 Jon Carstens
# SPDX-FileCopyrightText: 2025 Frank Hunleth
#
# SPDX-License-Identifier: Apache-2.0
#
defmodule Nerves.IntegrationTest do
  use NervesTest.Case, async: true

  @tag :tmp_dir
  @tag :integration
  test "bootstrap is called for other env packages", %{tmp_dir: tmp} do
    deps = ~w(system toolchain system_platform toolchain_platform)

    {_path, _env} = compile_fixture!("integration_app", tmp, deps)
  end
end
