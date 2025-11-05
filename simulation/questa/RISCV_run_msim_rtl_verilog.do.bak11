transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Program_Counter.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/RISCV.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Registers_Unit.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Imm_Generator.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/AluASrc.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/AluBSrc.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/ALU_Module.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Branch_Unit.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Sum4.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/PC_mux.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Data_Memory.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Write_Back_Data.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Control_Unit.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/hex7seg.sv}
vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/Instruction_Memory.sv}

vlog -sv -work work +incdir+C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design {C:/Users/maxim/Documents/U-6semestre/Arquitectura/RISCV_Monocycle_Design/TB_Riscv.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  TB_Riscv

add wave *
view structure
view signals
run -all
