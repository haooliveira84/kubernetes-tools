class KubernetesTools < Formula
  desc "Set of scripts that simplify daily Kubernetes operations"
  homepage "https://github.com/haooliveira84/kubernetes-tools"
  url "https://github.com/haooliveira84/kubernetes-tools/archive/refs/tags/v2.3.2.tar.gz"
  version "2.3.2"
  sha256 "d3238633be9fb0740d45a42ab19f10bfb96a3d4f5a9189fb3490def08d4d7681"
  license "MIT"

  depends_on "jq"
  depends_on "kubernetes-cli"

  def install
    bin.install Dir["bin/*"]

    bash_completion.install "completion/__completion" => "ktools"
    fish_completion.install "completion/kubernetes-tools.fish"

    # Point the zsh wrapper at the installed bash completion file so
    # bashcompinit can source it without depending on $PATH lookups.
    inreplace "completion/_ktools",
              "@BASH_COMPLETION_FILE@",
              "#{bash_completion}/ktools"
    zsh_completion.install "completion/_ktools"
  end

  def caveats
    <<~EOS
      Shell completion is installed automatically. If completions don't show
      up, make sure your shell loads Homebrew's completion paths:

        bash:  add to ~/.bashrc (requires bash-completion)
                 [[ -r "#{HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] && \\
                   . "#{HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"

        zsh:   ensure FPATH includes #{HOMEBREW_PREFIX}/share/zsh/site-functions
               (added by `brew shellenv`), then restart your shell.

        fish:  works out of the box via vendor_completions.d.

      Optional (recommended):
        brew install fzf        # nicer interactive pickers
        brew install colordiff  # colored kdiff output
    EOS
  end

  test do
    assert_match "Kubernetes Tools", shell_output("#{bin}/ktools -h")
    assert_match "kctx",  shell_output("#{bin}/ktools -h")
    assert_match "klogs", shell_output("#{bin}/ktools -h")

    assert_path_exists bash_completion/"ktools"
    assert_path_exists zsh_completion/"_ktools"
    assert_path_exists fish_completion/"kubernetes-tools.fish"
  end
end
