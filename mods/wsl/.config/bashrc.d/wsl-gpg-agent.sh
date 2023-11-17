# shellcheck shell=bash
# https://github.com/BlackReloaded/wsl2-ssh-pageant

export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

if ! pgrep -f wsl2-ssh-pageant > /dev/null; then
  # SSH
  rm -f "$SSH_AUTH_SOCK"
  (setsid nohup socat UNIX-LISTEN:"$SSH_AUTH_SOCK,fork" EXEC:"$HOME/.local/bin/wsl2-ssh-pageant.exe" >/dev/null 2>&1 &)

  # GPG
  systemctl --user disable gpg-agent.socket
  systemctl --user stop gpg-agent.socket
  gpg_agent_socket=$(gpgconf --list-dirs | sed -n 's/agent-socket://p')
  rm -f "$gpg_agent_socket"
  (setsid nohup socat UNIX-LISTEN:"$gpg_agent_socket,fork" EXEC:"$HOME/.local/bin/wsl2-ssh-pageant.exe --gpg S.gpg-agent" >/dev/null 2>&1 &)
  unset gpg_agent_socket
fi
