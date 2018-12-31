/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern void execute_2(char*, char *);
extern void execute_3(char*, char *);
extern void execute_118(char*, char *);
extern void execute_123(char*, char *);
extern void execute_599(char*, char *);
extern void execute_600(char*, char *);
extern void execute_601(char*, char *);
extern void execute_602(char*, char *);
extern void execute_603(char*, char *);
extern void execute_117(char*, char *);
extern void execute_594(char*, char *);
extern void execute_595(char*, char *);
extern void execute_596(char*, char *);
extern void execute_597(char*, char *);
extern void execute_598(char*, char *);
extern void execute_112(char*, char *);
extern void execute_113(char*, char *);
extern void vlog_const_rhs_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_127(char*, char *);
extern void execute_587(char*, char *);
extern void execute_588(char*, char *);
extern void execute_589(char*, char *);
extern void execute_7(char*, char *);
extern void execute_8(char*, char *);
extern void execute_125(char*, char *);
extern void execute_126(char*, char *);
extern void execute_494(char*, char *);
extern void execute_495(char*, char *);
extern void execute_496(char*, char *);
extern void execute_497(char*, char *);
extern void execute_498(char*, char *);
extern void execute_499(char*, char *);
extern void execute_510(char*, char *);
extern void execute_511(char*, char *);
extern void execute_512(char*, char *);
extern void execute_513(char*, char *);
extern void execute_515(char*, char *);
extern void execute_516(char*, char *);
extern void execute_517(char*, char *);
extern void execute_518(char*, char *);
extern void execute_522(char*, char *);
extern void execute_523(char*, char *);
extern void execute_531(char*, char *);
extern void execute_535(char*, char *);
extern void execute_536(char*, char *);
extern void execute_537(char*, char *);
extern void execute_538(char*, char *);
extern void execute_540(char*, char *);
extern void execute_541(char*, char *);
extern void execute_542(char*, char *);
extern void execute_543(char*, char *);
extern void execute_549(char*, char *);
extern void execute_550(char*, char *);
extern void execute_555(char*, char *);
extern void execute_561(char*, char *);
extern void execute_565(char*, char *);
extern void execute_566(char*, char *);
extern void execute_569(char*, char *);
extern void execute_570(char*, char *);
extern void execute_573(char*, char *);
extern void execute_574(char*, char *);
extern void execute_577(char*, char *);
extern void execute_578(char*, char *);
extern void execute_581(char*, char *);
extern void execute_582(char*, char *);
extern void execute_585(char*, char *);
extern void execute_586(char*, char *);
extern void execute_128(char*, char *);
extern void execute_111(char*, char *);
extern void vlog_simple_process_execute_0_fast_no_reg_no_agg(char*, char*, char*);
extern void vlog_simple_process_execute_1_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_475(char*, char *);
extern void execute_478(char*, char *);
extern void execute_479(char*, char *);
extern void execute_480(char*, char *);
extern void execute_483(char*, char *);
extern void execute_484(char*, char *);
extern void execute_485(char*, char *);
extern void execute_486(char*, char *);
extern void execute_487(char*, char *);
extern void execute_13(char*, char *);
extern void execute_14(char*, char *);
extern void execute_15(char*, char *);
extern void execute_16(char*, char *);
extern void execute_17(char*, char *);
extern void execute_18(char*, char *);
extern void execute_19(char*, char *);
extern void execute_20(char*, char *);
extern void execute_21(char*, char *);
extern void execute_22(char*, char *);
extern void execute_23(char*, char *);
extern void execute_24(char*, char *);
extern void execute_25(char*, char *);
extern void execute_26(char*, char *);
extern void execute_27(char*, char *);
extern void execute_28(char*, char *);
extern void execute_99(char*, char *);
extern void execute_100(char*, char *);
extern void execute_101(char*, char *);
extern void execute_102(char*, char *);
extern void execute_104(char*, char *);
extern void execute_105(char*, char *);
extern void execute_106(char*, char *);
extern void execute_107(char*, char *);
extern void execute_108(char*, char *);
extern void execute_109(char*, char *);
extern void execute_110(char*, char *);
extern void execute_360(char*, char *);
extern void execute_361(char*, char *);
extern void execute_364(char*, char *);
extern void execute_443(char*, char *);
extern void execute_444(char*, char *);
extern void execute_445(char*, char *);
extern void execute_452(char*, char *);
extern void execute_453(char*, char *);
extern void execute_454(char*, char *);
extern void execute_455(char*, char *);
extern void execute_456(char*, char *);
extern void execute_457(char*, char *);
extern void execute_458(char*, char *);
extern void execute_459(char*, char *);
extern void execute_460(char*, char *);
extern void execute_461(char*, char *);
extern void execute_462(char*, char *);
extern void execute_463(char*, char *);
extern void execute_464(char*, char *);
extern void execute_465(char*, char *);
extern void execute_466(char*, char *);
extern void execute_467(char*, char *);
extern void execute_468(char*, char *);
extern void execute_469(char*, char *);
extern void execute_470(char*, char *);
extern void execute_471(char*, char *);
extern void execute_472(char*, char *);
extern void execute_30(char*, char *);
extern void execute_31(char*, char *);
extern void execute_32(char*, char *);
extern void execute_33(char*, char *);
extern void execute_34(char*, char *);
extern void execute_35(char*, char *);
extern void execute_36(char*, char *);
extern void execute_40(char*, char *);
extern void execute_41(char*, char *);
extern void execute_42(char*, char *);
extern void execute_43(char*, char *);
extern void execute_44(char*, char *);
extern void execute_63(char*, char *);
extern void execute_64(char*, char *);
extern void execute_66(char*, char *);
extern void execute_68(char*, char *);
extern void execute_69(char*, char *);
extern void execute_71(char*, char *);
extern void execute_73(char*, char *);
extern void execute_75(char*, char *);
extern void execute_77(char*, char *);
extern void execute_365(char*, char *);
extern void execute_366(char*, char *);
extern void execute_367(char*, char *);
extern void execute_368(char*, char *);
extern void execute_369(char*, char *);
extern void execute_370(char*, char *);
extern void execute_371(char*, char *);
extern void execute_372(char*, char *);
extern void execute_373(char*, char *);
extern void execute_374(char*, char *);
extern void execute_375(char*, char *);
extern void execute_376(char*, char *);
extern void execute_379(char*, char *);
extern void execute_380(char*, char *);
extern void execute_381(char*, char *);
extern void execute_382(char*, char *);
extern void execute_383(char*, char *);
extern void execute_384(char*, char *);
extern void execute_385(char*, char *);
extern void execute_386(char*, char *);
extern void execute_387(char*, char *);
extern void execute_390(char*, char *);
extern void execute_391(char*, char *);
extern void execute_392(char*, char *);
extern void execute_393(char*, char *);
extern void execute_394(char*, char *);
extern void execute_395(char*, char *);
extern void execute_396(char*, char *);
extern void execute_397(char*, char *);
extern void execute_46(char*, char *);
extern void execute_47(char*, char *);
extern void execute_80(char*, char *);
extern void execute_81(char*, char *);
extern void execute_82(char*, char *);
extern void execute_83(char*, char *);
extern void execute_84(char*, char *);
extern void execute_85(char*, char *);
extern void execute_86(char*, char *);
extern void execute_87(char*, char *);
extern void execute_88(char*, char *);
extern void execute_89(char*, char *);
extern void execute_90(char*, char *);
extern void execute_91(char*, char *);
extern void execute_92(char*, char *);
extern void execute_93(char*, char *);
extern void execute_94(char*, char *);
extern void execute_96(char*, char *);
extern void execute_97(char*, char *);
extern void execute_98(char*, char *);
extern void execute_406(char*, char *);
extern void execute_407(char*, char *);
extern void execute_409(char*, char *);
extern void execute_417(char*, char *);
extern void execute_115(char*, char *);
extern void execute_116(char*, char *);
extern void execute_590(char*, char *);
extern void execute_591(char*, char *);
extern void execute_592(char*, char *);
extern void execute_593(char*, char *);
extern void execute_120(char*, char *);
extern void execute_121(char*, char *);
extern void execute_122(char*, char *);
extern void execute_604(char*, char *);
extern void execute_605(char*, char *);
extern void execute_606(char*, char *);
extern void execute_607(char*, char *);
extern void execute_608(char*, char *);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[223] = {(funcp)execute_2, (funcp)execute_3, (funcp)execute_118, (funcp)execute_123, (funcp)execute_599, (funcp)execute_600, (funcp)execute_601, (funcp)execute_602, (funcp)execute_603, (funcp)execute_117, (funcp)execute_594, (funcp)execute_595, (funcp)execute_596, (funcp)execute_597, (funcp)execute_598, (funcp)execute_112, (funcp)execute_113, (funcp)vlog_const_rhs_process_execute_0_fast_no_reg_no_agg, (funcp)execute_127, (funcp)execute_587, (funcp)execute_588, (funcp)execute_589, (funcp)execute_7, (funcp)execute_8, (funcp)execute_125, (funcp)execute_126, (funcp)execute_494, (funcp)execute_495, (funcp)execute_496, (funcp)execute_497, (funcp)execute_498, (funcp)execute_499, (funcp)execute_510, (funcp)execute_511, (funcp)execute_512, (funcp)execute_513, (funcp)execute_515, (funcp)execute_516, (funcp)execute_517, (funcp)execute_518, (funcp)execute_522, (funcp)execute_523, (funcp)execute_531, (funcp)execute_535, (funcp)execute_536, (funcp)execute_537, (funcp)execute_538, (funcp)execute_540, (funcp)execute_541, (funcp)execute_542, (funcp)execute_543, (funcp)execute_549, (funcp)execute_550, (funcp)execute_555, (funcp)execute_561, (funcp)execute_565, (funcp)execute_566, (funcp)execute_569, (funcp)execute_570, (funcp)execute_573, (funcp)execute_574, (funcp)execute_577, (funcp)execute_578, (funcp)execute_581, (funcp)execute_582, (funcp)execute_585, (funcp)execute_586, (funcp)execute_128, (funcp)execute_111, (funcp)vlog_simple_process_execute_0_fast_no_reg_no_agg, (funcp)vlog_simple_process_execute_1_fast_no_reg_no_agg, (funcp)execute_475, (funcp)execute_478, (funcp)execute_479, (funcp)execute_480, (funcp)execute_483, (funcp)execute_484, (funcp)execute_485, (funcp)execute_486, (funcp)execute_487, (funcp)execute_13, (funcp)execute_14, (funcp)execute_15, (funcp)execute_16, (funcp)execute_17, (funcp)execute_18, (funcp)execute_19, (funcp)execute_20, (funcp)execute_21, (funcp)execute_22, (funcp)execute_23, (funcp)execute_24, (funcp)execute_25, (funcp)execute_26, (funcp)execute_27, (funcp)execute_28, (funcp)execute_99, (funcp)execute_100, (funcp)execute_101, (funcp)execute_102, (funcp)execute_104, (funcp)execute_105, (funcp)execute_106, (funcp)execute_107, (funcp)execute_108, (funcp)execute_109, (funcp)execute_110, (funcp)execute_360, (funcp)execute_361, (funcp)execute_364, (funcp)execute_443, (funcp)execute_444, (funcp)execute_445, (funcp)execute_452, (funcp)execute_453, (funcp)execute_454, (funcp)execute_455, (funcp)execute_456, (funcp)execute_457, (funcp)execute_458, (funcp)execute_459, (funcp)execute_460, (funcp)execute_461, (funcp)execute_462, (funcp)execute_463, (funcp)execute_464, (funcp)execute_465, (funcp)execute_466, (funcp)execute_467, (funcp)execute_468, (funcp)execute_469, (funcp)execute_470, (funcp)execute_471, (funcp)execute_472, (funcp)execute_30, (funcp)execute_31, (funcp)execute_32, (funcp)execute_33, (funcp)execute_34, (funcp)execute_35, (funcp)execute_36, (funcp)execute_40, (funcp)execute_41, (funcp)execute_42, (funcp)execute_43, (funcp)execute_44, (funcp)execute_63, (funcp)execute_64, (funcp)execute_66, (funcp)execute_68, (funcp)execute_69, (funcp)execute_71, (funcp)execute_73, (funcp)execute_75, (funcp)execute_77, (funcp)execute_365, (funcp)execute_366, (funcp)execute_367, (funcp)execute_368, (funcp)execute_369, (funcp)execute_370, (funcp)execute_371, (funcp)execute_372, (funcp)execute_373, (funcp)execute_374, (funcp)execute_375, (funcp)execute_376, (funcp)execute_379, (funcp)execute_380, (funcp)execute_381, (funcp)execute_382, (funcp)execute_383, (funcp)execute_384, (funcp)execute_385, (funcp)execute_386, (funcp)execute_387, (funcp)execute_390, (funcp)execute_391, (funcp)execute_392, (funcp)execute_393, (funcp)execute_394, (funcp)execute_395, (funcp)execute_396, (funcp)execute_397, (funcp)execute_46, (funcp)execute_47, (funcp)execute_80, (funcp)execute_81, (funcp)execute_82, (funcp)execute_83, (funcp)execute_84, (funcp)execute_85, (funcp)execute_86, (funcp)execute_87, (funcp)execute_88, (funcp)execute_89, (funcp)execute_90, (funcp)execute_91, (funcp)execute_92, (funcp)execute_93, (funcp)execute_94, (funcp)execute_96, (funcp)execute_97, (funcp)execute_98, (funcp)execute_406, (funcp)execute_407, (funcp)execute_409, (funcp)execute_417, (funcp)execute_115, (funcp)execute_116, (funcp)execute_590, (funcp)execute_591, (funcp)execute_592, (funcp)execute_593, (funcp)execute_120, (funcp)execute_121, (funcp)execute_122, (funcp)execute_604, (funcp)execute_605, (funcp)execute_606, (funcp)execute_607, (funcp)execute_608, (funcp)vlog_transfunc_eventcallback};
const int NumRelocateId= 223;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/agc_monitor_tb_behav/xsim.reloc",  (void **)funcTab, 223);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/agc_monitor_tb_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void wrapper_func_0(char *dp)

{

}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/agc_monitor_tb_behav/xsim.reloc");
	wrapper_func_0(dp);

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/agc_monitor_tb_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/agc_monitor_tb_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/agc_monitor_tb_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}
