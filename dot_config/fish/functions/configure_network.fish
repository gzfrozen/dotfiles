function configure_network --description "Start/stop VPN with vpnutil and configure proxies on macOS for active network service (Wi‑Fi, Ethernet, USB, etc.)"
  # Usage:
  # configure_network "<VPN_NAME>" ["<NETWORK_SERVICE>"] [--pac URL | --http host:port [--https host:port]] [--socks host:port] [--off] [--show]
  # If <NETWORK_SERVICE> is omitted, auto-detects the active/primary network service (any type: Wi‑Fi, Ethernet, USB LAN, etc.)

  function _die
    echo $argv 1>&2
    return 1
  end

  function _need
    for cmd in vpnutil networksetup awk sed route
      if not command -q $cmd
        _die "Missing required command: $cmd (install or add to PATH)"
        return 1
      end
    end
  end

  function _run
    echo ">>> $argv"
    eval $argv
    if test $status -ne 0
      _die "Command failed: $argv"
      return 1
    end
  end

  if test (count $argv) -lt 1
    echo 'Usage: configure_network "<VPN_NAME>" ["<NETWORK_SERVICE>"] [--pac URL | --http host:port [--https host:port]] [--socks host:port] [--off] [--show"]'
    return 2
  end

  set -l VPN_NAME $argv[1]
  set -l USER_NET_SVC ""
  set -l argi 2

  # Optional positional NETWORK_SERVICE unless next arg is a flag
  if test (count $argv) -ge 2
    if not string match -q -- '--*' $argv[2]
      set USER_NET_SVC $argv[2]
      set argi 3
    end
  end

  # Flags
  set -l USE_PAC false
  set -l PAC_URL ""
  set -l USE_HTTP false
  set -l HTTP_HOST ""
  set -l HTTP_PORT ""
  set -l USE_HTTPS false
  set -l HTTPS_HOST ""
  set -l HTTPS_PORT ""
  set -l USE_SOCKS false
  set -l SOCKS_HOST ""
  set -l SOCKS_PORT ""
  set -l TURN_OFF false
  set -l SHOW_STATUS false

  # Parse options
  while test $argi -le (count $argv)
    set -l a $argv[$argi]
    switch $a
      case --pac
        set -l nxt (math $argi + 1)
        if test $nxt -le (count $argv)
          set USE_PAC true
          set PAC_URL $argv[$nxt]
          set argi (math $argi + 2)
        else
          return (_die "--pac requires a URL")
        end

      case --http
        set -l nxt (math $argi + 1)
        if test $nxt -le (count $argv)
          set -l hp $argv[$nxt]
          if string match -q "*:*" -- $hp
            set USE_HTTP true
            set HTTP_HOST (string split -m1 ":" $hp)[1]
            set HTTP_PORT (string split -m1 ":" $hp)[2]
            set argi (math $argi + 2)
          else
            return (_die "--http expects host:port")
          end
        else
          return (_die "--http requires host:port")
        end

      case --https
        set -l nxt (math $argi + 1)
        if test $nxt -le (count $argv)
          set -l hp $argv[$nxt]
          if string match -q "*:*" -- $hp
            set USE_HTTPS true
            set HTTPS_HOST (string split -m1 ":" $hp)[1]
            set HTTPS_PORT (string split -m1 ":" $hp)[2]
            set argi (math $argi + 2)
          else
            return (_die "--https expects host:port")
          end
        else
          return (_die "--https requires host:port")
        end

      case --socks
        set -l nxt (math $argi + 1)
        if test $nxt -le (count $argv)
          set -l hp $argv[$nxt]
          if string match -q "*:*" -- $hp
            set USE_SOCKS true
            set SOCKS_HOST (string split -m1 ":" $hp)[1]
            set SOCKS_PORT (string split -m1 ":" $hp)[2]
            set argi (math $argi + 2)
          else
            return (_die "--socks expects host:port")
          end
        else
          return (_die "--socks requires host:port")
        end

      case --off
        set TURN_OFF true
        set argi (math $argi + 1)

      case --show
        set SHOW_STATUS true
        set argi (math $argi + 1)

      case '--*'
        return (_die "Unknown option: $a")

      case '*'
        return (_die "Unexpected argument: $a")
    end
  end

  _need vpnutil networksetup awk sed route; or return 1

  # Auto-detect active network service if not provided
  set -l NET_SVC $USER_NET_SVC
  set -l PRIMARY_DEV ""

  if test -z "$NET_SVC"
    # Step 1: Get the primary/active interface via default route
    set PRIMARY_DEV (route -n get default 2>/dev/null | awk '/interface:/{print $2; exit}')

    # Step 2: Map that device to its service name from networksetup -listnetworkserviceorder
    if test -n "$PRIMARY_DEV"
      set NET_SVC (/usr/sbin/networksetup -listnetworkserviceorder \
        | awk -v dev="$PRIMARY_DEV" '
          /^\([0-9]+\) / {
            svc = $0
            sub(/^\([0-9]+\) /, "", svc)
            getline
            if ($0 ~ "Device: " dev ")") {
              print svc
              exit
            }
          }
        ')
    end

    # Step 3: Fallback to the first enabled network service if still empty
    if test -z "$NET_SVC"
      set NET_SVC (/usr/sbin/networksetup -listallnetworkservices \
        | grep -v '^An asterisk' \
        | grep -v '^\*' \
        | head -n 1)
    end

    # Step 4: Final safety fallback
    if test -z "$NET_SVC"
      set NET_SVC "Wi-Fi"
    end
  end

  if test "$TURN_OFF" = "true"
    echo "Turning off proxies on $NET_SVC"
    _run "networksetup -setwebproxystate \"$NET_SVC\" off"; or return 1
    _run "networksetup -setsecurewebproxystate \"$NET_SVC\" off"; or return 1
    _run "networksetup -setsocksfirewallproxystate \"$NET_SVC\" off"; or return 1
    _run "networksetup -setautoproxystate \"$NET_SVC\" off"; or return 1
    echo "Stopping VPN via vpnutil: $VPN_NAME"
    vpnutil stop "$VPN_NAME" >/dev/null 2>&1
  else
    echo "Starting VPN via vpnutil: $VPN_NAME"
    vpnutil start "$VPN_NAME" >/dev/null 2>&1

    if test "$USE_PAC" = "true"
      echo "Using PAC URL: $PAC_URL on $NET_SVC"
      _run "networksetup -setautoproxyurl \"$NET_SVC\" \"$PAC_URL\""; or return 1
      _run "networksetup -setautoproxystate \"$NET_SVC\" on"; or return 1
      _run "networksetup -setwebproxystate \"$NET_SVC\" off"; or return 1
      _run "networksetup -setsecurewebproxystate \"$NET_SVC\" off"; or return 1
    else
      if test "$USE_HTTP" = "true"
        _run "networksetup -setwebproxy \"$NET_SVC\" \"$HTTP_HOST\" $HTTP_PORT"; or return 1
        _run "networksetup -setwebproxystate \"$NET_SVC\" on"; or return 1
      end
      if test "$USE_HTTPS" = "true"
        _run "networksetup -setsecurewebproxy \"$NET_SVC\" \"$HTTPS_HOST\" $HTTPS_PORT"; or return 1
        _run "networksetup -setsecurewebproxystate \"$NET_SVC\" on"; or return 1
      end
    end

    if test "$USE_SOCKS" = "true"
      _run "networksetup -setsocksfirewallproxy \"$NET_SVC\" \"$SOCKS_HOST\" $SOCKS_PORT"; or return 1
      _run "networksetup -setsocksfirewallproxystate \"$NET_SVC\" on"; or return 1
    end
  end

  if test "$SHOW_STATUS" = "true"
    echo
    echo "Detected active network service: $NET_SVC"
    if test -n "$PRIMARY_DEV"
      echo "Primary interface device: $PRIMARY_DEV"
      # Try to get IP address for display
      set -l ip_addr (ipconfig getifaddr $PRIMARY_DEV 2>/dev/null)
      if test -n "$ip_addr"
        echo "IP address: $ip_addr"
      end
    end
    echo
    echo "VPN (vpnutil) last action attempted on: $VPN_NAME"
    echo
    echo "Web proxy:"
    networksetup -getwebproxy "$NET_SVC"
    echo
    echo "Secure web proxy:"
    networksetup -getsecurewebproxy "$NET_SVC"
    echo
    echo "Auto proxy:"
    networksetup -getautoproxyurl "$NET_SVC"
  end
end
