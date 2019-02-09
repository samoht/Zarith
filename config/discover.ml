module C = Configurator.V1
module OV = Ocaml_version
open Printf

let () =
  C.main ~name:"zarith" (fun c ->
    let arch = C.ocaml_config_var_exn c "architecture" in
    let system = C.ocaml_config_var_exn c "system" in
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
    let arch_defines =
      match arch, system with
      | "amd64", ("linux"|"freebsd") -> ["-DZ_ELF";"-DZ_DOT_LABEL_PREFIX"]
      | "amd64", "macosx" -> ["-DZ_UNDERSCORE_PREFIX";"-DZ_MACOS";"-arch";"x86_64"]
      | _ -> failwith (sprintf "%s/%s not yet added to dune discover.ml. TODO!" arch system) in
    let defines = defines @ c_api_defines @ arch_defines in
    let cflags = cflags @ defines in
    let asflags = defines in
    let ldflags = ["-lgmp"] in (* TODO detectionj *)
    C.Flags.write_sexp "cflags.sxp" cflags;
    C.Flags.write_lines "asflags" asflags;
    C.Flags.write_lines "cflags" cflags;
    C.Flags.write_sexp "ldflags.sxp" ldflags)
