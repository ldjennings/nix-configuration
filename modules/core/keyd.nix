{...}:
{
  services.keyd = {
    enable = true;

    keyboards = {
      default = {
        ids = [ "*" ];
        settings = {
          # global = {

          # };
          main = {
            capslock = "delete";
          };
          control = {
            capslock = "capslock";
          };
        };
        # from (NIX-STORE)/share/keyd/layouts/colemak. There were issues with file inclusion so had to manually put it here.
        extraConfig = ''
          [colemak:layout]

          w = w
          , = ,
          s = r
          a = a
          c = c
          g = d
          q = q
          e = f
          ] = ]
          d = s
          / = /
          ; = o
          ' = '
          r = p
          f = t
          t = g
          u = l
          . = .
          j = n
          k = e
          p = ;
          o = y
          z = z
          h = h
          i = u
          [ = [
          v = v
          l = i
          m = m
          n = k
          x = x
          b = b
          y = j
          [global]
          default_layout = colemak
        '';
      };
    };
  };
}