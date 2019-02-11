module C = Configurator.V1
module OV = Ocaml_version
open Printf

(* Returns arch, ccdef, opt (cc/as)  *)
let x86_64_def = 
  "x86_64", ["-DZ_ELF";"-DZ_DOT_LABEL_PREFIX"], []

let i686_def = 
  "i686", ["-DZ_ELF";"-DZ_DOT_LABEL_PREFIX"], []

let cygwin_def word_size =
  match word_size with
  | "64" -> "x86_64_mingw64", ["-DZ_COFF"], []
  | _ -> "i686", ["-DZ_UNDERSCORE_PREFIX";"-DZ_COFF"], []

let darwin_def word_size =
  match word_size with
  | "64" -> "x86_64", ["-DZ_UNDERSCORE_PREFIX";"-DZ_MACOS"], ["-arch x86_64"]
  | _ -> "i686", ["-DZ_UNDERSCORE_PREFIX";"-DZ_MACOS"], ["-arch i386"]

let arm_def = "arm", [], []

let no_def = "", [], []

let extract_from_target word_size str =
  let reg_all = "\\(.*\\)"
  and reg_or = "\\|"
  in
  let x86_64 = Str.regexp ("x86_64"^reg_all^"-linux-gnu"^reg_or^"x86_64-kfreebsd-gnu")
  and i686 = Str.regexp ("i486-"^reg_all^"linux-gnu"^reg_or^"i686-"^reg_all^"linux-gnu"^reg_or^"i486-kfreebsd-gnu")
  and cygwin = Str.regexp ("i686-"^reg_all^"cygwin")
  and darwin = Str.regexp ("i386-"^reg_all^"darwin"^reg_all^reg_or^"x86_64-"^reg_all^"darwin"^reg_all)
  and arm = Str.regexp ("armv7"^reg_all^"-gnueabi")
  in
  if Str.string_match x86_64 str 0
  then x86_64_def
  else if Str.string_match i686 str 0
  then i686_def
  else if Str.string_match cygwin str 0
  then cygwin_def word_size
  else if Str.string_match darwin str 0
  then darwin_def word_size
  else if Str.string_match arm str 0
  then arm_def
  else
       no_def

let () =
  C.main ~name:"zarith" (fun c ->
    let word_size = C.ocaml_config_var_exn c "word_size" in
    let machine, arch_defines, opt = C.ocaml_config_var_exn c "target" |> extract_from_target word_size in
    let ov = C.ocaml_config_var_exn c "version" |> OV.of_string_exn in
    let stdlib_include = sprintf "-I%s" (C.ocaml_config_var_exn c "standard_library") in
    let cflags = stdlib_include :: ["-O3";"-Wall";"-Wextra"] in
    let defines = ["-DZ_OCAML_COMPARE_EXT"; "-DZ_OCAML_HASH"] in
    (* TODO assume GMP not MPIR for now *)
    let defines = "-DHAS_GMP" :: defines in
    let c_api_defines =
      match Ocaml_version.(compare ov Releases.v4_08) with
      |(-1) -> ["-DZ_OCAML_LEGACY_CUSTOM_OPERATIONS"]
      |_ -> [] in
    let defines = defines @ c_api_defines @ arch_defines in
    let cflags = cflags @ opt @ defines in
    let asflags = defines @ opt in
    let ldflags = ["-lgmp"] in (* TODO detectionj *)
    C.Flags.write_sexp "cflags.sxp" cflags;
    C.Flags.write_lines "asflags" asflags;
    C.Flags.write_lines "cflags" cflags;
    C.Flags.write_sexp "ldflags.sxp" ldflags;
    C.Flags.write_lines "arch" [machine])
