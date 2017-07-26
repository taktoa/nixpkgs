# to run these tests:
# nix-instantiate --eval --strict nixpkgs/lib/tests/misc.nix
# if the resulting list is empty, all tests passed
with import ../default.nix;

runTests {


# TRIVIAL

  testId = {
    expr = id 1;
    expected = 1;
  };

  testConst = {
    expr = const 2 3;
    expected = 2;
  };

  /*
  testOr = {
    expr = or true false;
    expected = true;
  };
  */

  testAnd = {
    expr = and true false;
    expected = false;
  };

  testFix = {
    expr = fix (x: {a = if x ? a then "a" else "b";});
    expected = {a = "a";};
  };

  testComposeExtensions = {
    expr = let obj = makeExtensible (self: { foo = self.bar; });
               f = self: super: { bar = false; baz = true; };
               g = self: super: { bar = super.baz or false; };
               f_o_g = composeExtensions f g;
               composed = obj.extend f_o_g;
           in composed.foo;
    expected = true;
  };

# STRINGS

  testConcatMapStrings = {
    expr = concatMapStrings (x: x + ";") ["a" "b" "c"];
    expected = "a;b;c;";
  };

  testConcatStringsSep = {
    expr = concatStringsSep "," ["a" "b" "c"];
    expected = "a,b,c";
  };

  testSplitStringsSimple = {
    expr = strings.splitString "." "a.b.c.d";
    expected = [ "a" "b" "c" "d" ];
  };

  testSplitStringsEmpty = {
    expr = strings.splitString "." "a..b";
    expected = [ "a" "" "b" ];
  };

  testSplitStringsOne = {
    expr = strings.splitString ":" "a.b";
    expected = [ "a.b" ];
  };

  testSplitStringsNone = {
    expr = strings.splitString "." "";
    expected = [ "" ];
  };

  testSplitStringsFirstEmpty = {
    expr = strings.splitString "/" "/a/b/c";
    expected = [ "" "a" "b" "c" ];
  };

  testSplitStringsLastEmpty = {
    expr = strings.splitString ":" "2001:db8:0:0042::8a2e:370:";
    expected = [ "2001" "db8" "0" "0042" "" "8a2e" "370" "" ];
  };

  testParseDomain = {
    expr = map strings.parseDomain [
      "nixos.org" "foo.bar.baz" "foo" ""
      "...." "foo..bar" "foo." ".foo"
    ];
    expected = [
      { components = ["nixos" "org"]; }
      { components = ["foo" "bar" "baz"]; }
      { components = ["foo"]; }
      { components = []; }
      null null null null
    ];
  };

  testParseEmail = {
    expr = map strings.parseEmail [
      # Simple tests
      "hydra@nixos.org"
      "\"quoted\"@nixos.org"
      ""
      "invalid"
      "invalid@"
      ".invalid@nixos.org"
      "invalid.@nixos.org"
      "invalid@garbage@nixos.org"

      # All of these should be valid
      "prettyandsimple@example.com"
      "very.common@example.com"
      "disposable.email.with+symbol@example.com"
      "other.email-with-dash@example.com"
      "-starts-with-dash@example.com"
      "ends-with-dash-@example.com"
      "fully-qualified-domain@example.com."
      "x@example.com"
      "\"very.weird.@.weird.com\"@example.com"
      "\"very.(),:;<>[]\\\".ODD.\\\"very@\\\\ \\\"very\\\".odd\"@weird.com"
      "example-indeed@strange-example.com"
      "admin@mailserver1"
      "#!$%&'*+-/=?^_`{}|~@example.com"
      "\"()<>[]:,;@\\\\\\\"!#$%&'-/=?^_`{}| ~.a\"@example.com"
      "\" \"@example.com"
      "example@s.solutions"
      "user@localserver"
      "user@[IPv6:2001:DB8::1]"

      # All of these should be invalid

      ### No @ character:
      "Abc.example.com"

      ### Only one @ is allowed outside quotation marks:
      "A@b@c@example.com"

      ### None of the special characters in this local-part are allowed outside
      ### quotation marks:
      "a\"b(c)d,e:f;g<h>i[j\\k]l@example.com"

      ### Quoted strings must be dot separated or the only element making up
      ### the local-part:
      "just\"not\"right@example.com"

      ### Spaces, quotes, and backslashes may only exist when within quoted
      ### strings and preceded by a backslash:
      "this is\"not\\allowed@example.com"

      ### Even if escaped (preceded by a backslash), spaces, quotes, and
      ### backslashes must still be contained by quotes:
      "this\\ still\\\"not\\\\allowed@example.com"

      ### Too long:
      "1234567890123456789012345678901234567890123456789012345678901234+x@example.com"

      ### Double dot before `@`:
      "john..doe@example.com"

      ### Sent from localhost:
      "example@localhost"
    ];
    expected = [
      { localPart = "hydra";      domain = "nixos.org"; }
      { localPart = "\"quoted\""; domain = "nixos.org"; }
      null null null null null null

      { localPart = "prettyandsimple";              domain = "example.com"; }
      { localPart = "very.common";                  domain = "example.com"; }
      { localPart = "disposable.email.with+symbol"; domain = "example.com"; }
      { localPart = "other.email-with-dash";        domain = "example.com"; }
      { localPart = "-starts-with-dash";            domain = "example.com"; }
      { localPart = "ends-with-dash-";              domain = "example.com"; }
      { localPart = "fully-qualified-domain";       domain = "example.com."; }
      { localPart = "x";                            domain = "example.com"; }
      { localPart = "\"very.weird.@.weird.com\"";   domain = "example.com"; }
      { localPart = "\"very.weird.@.weird.com\"";   domain = "example.com"; }
      {
        localPart = "\"very.(),:;<>[]\\\".ODD.\\\"very@\\\\ \\\"very\\\".odd\"";
        domain    = "weird.com";
      }
      { localPart = "example-indeed";      domain = "strange-example.com"; }
      { localPart = "admin";               domain = "mailserver1"; }
      { localPart = "#!$%&'*+-/=?^_`{}|~"; domain = "example.com"; }
      {
        localPart = "\"()<>[]:,;@\\\\\\\"!#$%&'-/=?^_`{}| ~.a\"";
        domain = "example.com";
      }
      { localPart = "\" \"";   domain = "example.com"; }
      { localPart = "example"; domain = "s.solutions"; }
      { localPart = "user";    domain = "localserver"; }
      { localPart = "user";    domain = "[IPv6:2001:DB8::1]"; }

      null null null null null null null null null
    ];
  };

  testIsStorePath =  {
    expr =
      let goodPath =
            "${builtins.storeDir}/d945ibfx9x185xf04b890y4f9g3cbb63-python-2.7.11";
      in {
        storePath = isStorePath goodPath;
        storePathAppendix = isStorePath
          "${goodPath}/bin/python";
        nonAbsolute = isStorePath (concatStrings (tail (stringToCharacters goodPath)));
        asPath = isStorePath (builtins.toPath goodPath);
        otherPath = isStorePath "/something/else";
        otherVals = {
          attrset = isStorePath {};
          list = isStorePath [];
          int = isStorePath 42;
        };
      };
    expected = {
      storePath = true;
      storePathAppendix = false;
      nonAbsolute = false;
      asPath = true;
      otherPath = false;
      otherVals = {
        attrset = false;
        list = false;
        int = false;
      };
    };
  };

# LISTS

  testFilter = {
    expr = filter (x: x != "a") ["a" "b" "c" "a"];
    expected = ["b" "c"];
  };

  testFold =
    let
      f = op: fold: fold op 0 (range 0 100);
      # fold with associative operator
      assoc = f builtins.add;
      # fold with non-associative operator
      nonAssoc = f builtins.sub;
    in {
      expr = {
        assocRight = assoc foldr;
        # right fold with assoc operator is same as left fold
        assocRightIsLeft = assoc foldr == assoc foldl;
        nonAssocRight = nonAssoc foldr;
        nonAssocLeft = nonAssoc foldl;
        # with non-assoc operator the fold results are not the same
        nonAssocRightIsNotLeft = nonAssoc foldl != nonAssoc foldr;
        # fold is an alias for foldr
        foldIsRight = nonAssoc fold == nonAssoc foldr;
      };
      expected = {
        assocRight = 5050;
        assocRightIsLeft = true;
        nonAssocRight = 50;
        nonAssocLeft = (-5050);
        nonAssocRightIsNotLeft = true;
        foldIsRight = true;
      };
    };

  testTake = testAllTrue [
    ([] == (take 0 [  1 2 3 ]))
    ([1] == (take 1 [  1 2 3 ]))
    ([ 1 2 ] == (take 2 [  1 2 3 ]))
    ([ 1 2 3 ] == (take 3 [  1 2 3 ]))
    ([ 1 2 3 ] == (take 4 [  1 2 3 ]))
  ];

  testFoldAttrs = {
    expr = foldAttrs (n: a: [n] ++ a) [] [
    { a = 2; b = 7; }
    { a = 3;        c = 8; }
    ];
    expected = { a = [ 2 3 ]; b = [7]; c = [8];};
  };

  testSort = {
    expr = sort builtins.lessThan [ 40 2 30 42 ];
    expected = [2 30 40 42];
  };

  testToIntShouldConvertStringToInt = {
    expr = toInt "27";
    expected = 27;
  };

  testToIntShouldThrowErrorIfItCouldNotConvertToInt = {
    expr = builtins.tryEval (toInt "\"foo\"");
    expected = { success = false; value = false; };
  };

  testHasAttrByPathTrue = {
    expr = hasAttrByPath ["a" "b"] { a = { b = "yey"; }; };
    expected = true;
  };

  testHasAttrByPathFalse = {
    expr = hasAttrByPath ["a" "b"] { a = { c = "yey"; }; };
    expected = false;
  };

  testComposeList = {
    expr = [
      (composeList [] 5)
      (composeList [(x: x + 1) (x: x * 2)] 5)
      (composeList [(x: x * 2) (x: x + 1)] 5)
    ];
    expected = [5 12 11];
  };

# GENERATORS
# these tests assume attributes are converted to lists
# in alphabetical order

  testMkKeyValueDefault = {
    expr = generators.mkKeyValueDefault ":" "f:oo" "bar";
    expected = ''f\:oo:bar'';
  };

  testToKeyValue = {
    expr = generators.toKeyValue {} {
      key = "value";
      "other=key" = "baz";
    };
    expected = ''
      key=value
      other\=key=baz
    '';
  };

  testToINIEmpty = {
    expr = generators.toINI {} {};
    expected = "";
  };

  testToINIEmptySection = {
    expr = generators.toINI {} { foo = {}; bar = {}; };
    expected = ''
      [bar]

      [foo]
    '';
  };

  testToINIDefaultEscapes = {
    expr = generators.toINI {} {
      "no [ and ] allowed unescaped" = {
        "and also no = in keys" = 42;
      };
    };
    expected = ''
      [no \[ and \] allowed unescaped]
      and also no \= in keys=42
    '';
  };

  testToINIDefaultFull = {
    expr = generators.toINI {} {
      "section 1" = {
        attribute1 = 5;
        x = "Me-se JarJar Binx";
      };
      "foo[]" = {
        "he\\h=he" = "this is okay";
      };
    };
    expected = ''
      [foo\[\]]
      he\h\=he=this is okay

      [section 1]
      attribute1=5
      x=Me-se JarJar Binx
    '';
  };

  /* right now only invocation check */
  testToJSONSimple =
    let val = {
      foobar = [ "baz" 1 2 3 ];
    };
    in {
      expr = generators.toJSON {} val;
      # trivial implementation
      expected = builtins.toJSON val;
  };

  /* right now only invocation check */
  testToYAMLSimple =
    let val = {
      list = [ { one = 1; } { two = 2; } ];
      all = 42;
    };
    in {
      expr = generators.toYAML {} val;
      # trivial implementation
      expected = builtins.toJSON val;
  };

  testToPretty = {
    expr = mapAttrs (const (generators.toPretty {})) rec {
      int = 42;
      bool = true;
      string = "fnord";
      null_ = null;
      function = x: x;
      functionArgs = { arg ? 4, foo }: arg;
      list = [ 3 4 function [ false ] ];
      attrs = { foo = null; "foo bar" = "baz"; };
      drv = derivation { name = "test"; system = builtins.currentSystem; };
    };
    expected = rec {
      int = "42";
      bool = "true";
      string = "\"fnord\"";
      null_ = "null";
      function = "<λ>";
      functionArgs = "<λ:{(arg),foo}>";
      list = "[ 3 4 ${function} [ false ] ]";
      attrs = "{ \"foo\" = null; \"foo bar\" = \"baz\"; }";
      drv = "<δ>";
    };
  };

  testToPrettyAllowPrettyValues = {
    expr = generators.toPretty { allowPrettyValues = true; }
             { __pretty = v: "«" + v + "»"; val = "foo"; };
    expected  = "«foo»";
  };


# MISC

  testOverridableDelayableArgsTest = {
    expr =
      let res1 = defaultOverridableDelayableArgs id {};
          res2 = defaultOverridableDelayableArgs id { a = 7; };
          res3 = let x = defaultOverridableDelayableArgs id { a = 7; };
                 in (x.merge) { b = 10; };
          res4 = let x = defaultOverridableDelayableArgs id { a = 7; };
                in (x.merge) ( x: { b = 10; });
          res5 = let x = defaultOverridableDelayableArgs id { a = 7; };
                in (x.merge) ( x: { a = builtins.add x.a 3; });
          res6 = let x = defaultOverridableDelayableArgs id { a = 7; mergeAttrBy = { a = builtins.add; }; };
                     y = x.merge {};
                in (y.merge) { a = 10; };

          resRem7 = res6.replace (a: removeAttrs a ["a"]);

          resReplace6 = let x = defaultOverridableDelayableArgs id { a = 7; mergeAttrBy = { a = builtins.add; }; };
                            x2 = x.merge { a = 20; }; # now we have 27
                        in (x2.replace) { a = 10; }; # and override the value by 10

          # fixed tests (delayed args): (when using them add some comments, please)
          resFixed1 =
                let x = defaultOverridableDelayableArgs id ( x: { a = 7; c = x.fixed.b; });
                    y = x.merge (x: { name = "name-${builtins.toString x.fixed.c}"; });
                in (y.merge) { b = 10; };
          strip = attrs: removeAttrs attrs ["merge" "replace"];
      in all id
        [ ((strip res1) == { })
          ((strip res2) == { a = 7; })
          ((strip res3) == { a = 7; b = 10; })
          ((strip res4) == { a = 7; b = 10; })
          ((strip res5) == { a = 10; })
          ((strip res6) == { a = 17; })
          ((strip resRem7) == {})
          ((strip resFixed1) == { a = 7; b = 10; c =10; name = "name-10"; })
        ];
    expected = true;
  };

}
