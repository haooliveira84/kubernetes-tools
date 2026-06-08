class KubernetesTools < Formula
  desc "Set of scripts that simplify daily Kubernetes operations"
  homepage "https://github.com/haooliveira84/kubernetes-tools"
  url "https://github.com/haooliveira84/kubernetes-tools/archive/refs/tags/v2.3.3.tar.gz"
  version "2.3.3"
  sha256 "34f0f898a96da1bb96335ee559ee99e32c19a71ebbf309ce6f602b5b2106347c"
  license "MIT"

  depends_on "jq"
  depends_on "kubernetes-cli"

  KTOOLS_COMPLETED_COMMANDS = %w[
    klogs kexec kcopy kpod kdebug kevents
    kns kctx knode krestart kscale kpf ksecret
  ].freeze

  def install
    bin.install Dir["bin/*"]

    # Symlink per command so bash-completion v2's lazy loader (lookup by
    # command name) finds the file when the user hits <TAB> on klogs, kctx, ...
    bash_completion.install "completion/__completion" => "ktools"
    KTOOLS_COMPLETED_COMMANDS.each do |cmd|
      bash_completion.install_symlink "ktools" => cmd
    end

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
    KTOOLS_COMPLETED_COMMANDS.each do |cmd|
      assert_path_exists bash_completion/cmd
    end
    assert_path_exists zsh_completion/"_ktools"
    assert_path_exists fish_completion/"kubernetes-tools.fish"
  end
end
