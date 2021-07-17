{ lib, buildPythonApplication, fetchFromGitHub, pythonOlder, file, fetchpatch
, cairo, ffmpeg, sox, xdg-utils
, colour, numpy, pillow, progressbar, scipy, tqdm, opencv , pycairo, pydub
, pygments, mapbox-earcut, networkx, rich, click-default-group
, moderngl-window, cloup, watchdog, manimpango, screeninfo, decorator
, pbr, fetchPypi
}:

buildPythonApplication rec {
  pname = "manim";
  version = "0.8.0";

  src = fetchPypi {
    pname = "manim";
    inherit version;
    sha256 = "07giymxqwxjnk1i6iqy9961fcwppwaaw7nvygb1zg7lfaks0akjy";
  };

  nativeBuildInputs = [ pbr ];

  propagatedBuildInputs = [
    colour
    numpy
    pillow
    progressbar
    scipy
    tqdm
    opencv
    pycairo
    pydub
    pygments
    mapbox-earcut
    networkx
    rich
    click-default-group
    moderngl-window
    cloup
    watchdog
    manimpango
    screeninfo
    decorator

    cairo sox ffmpeg xdg-utils
  ];

  dontUseSetuptoolsCheck = true;
  dontCheck = true;

  disabled = pythonOlder "3.7";

  meta = {
    description = "Animation engine for explanatory math videos";
    longDescription = ''
      Manim is an animation engine for explanatory math videos. It's used to
      create precise animations programmatically, as seen in the videos of
      3Blue1Brown on YouTube.
    '';
    homepage = "https://github.com/3b1b/manim";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ johnazoidberg ];
  };
}
