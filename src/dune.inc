(rule
  (targets z.ml z_features.h)
  (deps (:script z_pp.exe) z_pp.ml z.mlp z.mlip ../../META caml_z_arch.S)
  (action (run %{script} -ml -h -ov %{ocaml_version} %{read-lines:../../config/arch})))

(rule
  (targets caml_z_arch.S)
  (deps ../caml_z_arm.S ../caml_z_i686.S ../caml_z_x86_64.S ../caml_z_x86_64_mingw64.S)
  (action (copy ../caml_z_%{read-lines:../../config/arch}.S caml_z_arch.S)))

(executable
 (name z_pp)
 (modules z_pp)
 (libraries str))

(rule
  (targets z_pp.ml)
  (deps ../z_pp.ml)
  (action (copy ../z_pp.ml z_pp.ml)))

(rule
  (targets z.mlp)
  (deps ../z.mlp)
  (action (copy ../z.mlp z.mlp)))

(rule
  (targets q.ml)
  (deps ../q.ml)
  (action (copy ../q.ml q.ml)))

(rule
  (targets zarith.h)
  (deps ../zarith.h)
  (action (copy ../zarith.h zarith.h)))

(rule
  (targets z.mlip)
  (deps ../zarith-virtual/z.mlip)
  (action (copy ../zarith-virtual/z.mlip z.mlip)))
(rule
  (targets caml_z.c)
  (deps ../caml_z.c)
  (action (copy ../caml_z.c caml_z.c)))

(rule
  (targets big_int_Z.ml)
  (deps ../big_int_Z.ml)
  (action (copy ../big_int_Z.ml big_int_Z.ml)))
