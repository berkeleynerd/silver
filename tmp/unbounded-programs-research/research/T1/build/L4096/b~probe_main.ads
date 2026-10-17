pragma Warnings (Off);
pragma Ada_95;
with System;
with System.Parameters;
with System.Secondary_Stack;
package ada_main is

   gnat_argc : Integer;
   gnat_argv : System.Address;
   gnat_envp : System.Address;

   pragma Import (C, gnat_argc);
   pragma Import (C, gnat_argv);
   pragma Import (C, gnat_envp);

   gnat_exit_status : Integer;
   pragma Import (C, gnat_exit_status);

   GNAT_Version : constant String :=
                    "GNAT Version: 16.1.0" & ASCII.NUL;
   pragma Export (C, GNAT_Version, "__gnat_version");

   GNAT_Version_Address : constant System.Address := GNAT_Version'Address;
   pragma Export (C, GNAT_Version_Address, "__gnat_version_address");

   Ada_Main_Program_Name : constant String := "_ada_probe_main" & ASCII.NUL;
   pragma Export (C, Ada_Main_Program_Name, "__gnat_ada_main_program_name");

   procedure adainit;
   pragma Export (C, adainit, "adainit");

   procedure adafinal;
   pragma Export (C, adafinal, "adafinal");

   function main
     (argc : Integer;
      argv : System.Address;
      envp : System.Address)
      return Integer;
   pragma Export (C, main, "main");

   type Version_32 is mod 2 ** 32;
   u00001 : constant Version_32 := 16#2976e7d4#;
   pragma Export (C, u00001, "probe_mainB");
   u00002 : constant Version_32 := 16#b2cfab41#;
   pragma Export (C, u00002, "system__standard_libraryB");
   u00003 : constant Version_32 := 16#f0b96e04#;
   pragma Export (C, u00003, "system__standard_libraryS");
   u00004 : constant Version_32 := 16#76789da1#;
   pragma Export (C, u00004, "adaS");
   u00005 : constant Version_32 := 16#9fbfddeb#;
   pragma Export (C, u00005, "ada__calendarB");
   u00006 : constant Version_32 := 16#c907a168#;
   pragma Export (C, u00006, "ada__calendarS");
   u00007 : constant Version_32 := 16#04356d51#;
   pragma Export (C, u00007, "ada__exceptionsB");
   u00008 : constant Version_32 := 16#677117e5#;
   pragma Export (C, u00008, "ada__exceptionsS");
   u00009 : constant Version_32 := 16#85bf25f7#;
   pragma Export (C, u00009, "ada__exceptions__last_chance_handlerB");
   u00010 : constant Version_32 := 16#c1262c0b#;
   pragma Export (C, u00010, "ada__exceptions__last_chance_handlerS");
   u00011 : constant Version_32 := 16#e2b7c99d#;
   pragma Export (C, u00011, "systemS");
   u00012 : constant Version_32 := 16#7fa0a598#;
   pragma Export (C, u00012, "system__soft_linksB");
   u00013 : constant Version_32 := 16#c40bf0df#;
   pragma Export (C, u00013, "system__soft_linksS");
   u00014 : constant Version_32 := 16#33935a56#;
   pragma Export (C, u00014, "system__secondary_stackB");
   u00015 : constant Version_32 := 16#d845cfdc#;
   pragma Export (C, u00015, "system__secondary_stackS");
   u00016 : constant Version_32 := 16#3007a9ef#;
   pragma Export (C, u00016, "system__parametersB");
   u00017 : constant Version_32 := 16#431962c1#;
   pragma Export (C, u00017, "system__parametersS");
   u00018 : constant Version_32 := 16#2e691d75#;
   pragma Export (C, u00018, "system__storage_elementsS");
   u00019 : constant Version_32 := 16#0286ce9f#;
   pragma Export (C, u00019, "system__soft_links__initializeB");
   u00020 : constant Version_32 := 16#ac2e8b53#;
   pragma Export (C, u00020, "system__soft_links__initializeS");
   u00021 : constant Version_32 := 16#8599b27b#;
   pragma Export (C, u00021, "system__stack_checkingB");
   u00022 : constant Version_32 := 16#25e8dc8b#;
   pragma Export (C, u00022, "system__stack_checkingS");
   u00023 : constant Version_32 := 16#45e1965e#;
   pragma Export (C, u00023, "system__exception_tableB");
   u00024 : constant Version_32 := 16#6f9cbf84#;
   pragma Export (C, u00024, "system__exception_tableS");
   u00025 : constant Version_32 := 16#d01276af#;
   pragma Export (C, u00025, "system__exceptionsS");
   u00026 : constant Version_32 := 16#c367aa24#;
   pragma Export (C, u00026, "system__exceptions__machineB");
   u00027 : constant Version_32 := 16#8d1d496c#;
   pragma Export (C, u00027, "system__exceptions__machineS");
   u00028 : constant Version_32 := 16#2f7ce883#;
   pragma Export (C, u00028, "system__exceptions_debugB");
   u00029 : constant Version_32 := 16#d2b991ce#;
   pragma Export (C, u00029, "system__exceptions_debugS");
   u00030 : constant Version_32 := 16#7597daaf#;
   pragma Export (C, u00030, "system__img_intS");
   u00031 : constant Version_32 := 16#5c7d9c20#;
   pragma Export (C, u00031, "system__tracebackB");
   u00032 : constant Version_32 := 16#642d3d20#;
   pragma Export (C, u00032, "system__tracebackS");
   u00033 : constant Version_32 := 16#5f6b6486#;
   pragma Export (C, u00033, "system__traceback_entriesB");
   u00034 : constant Version_32 := 16#2aab7611#;
   pragma Export (C, u00034, "system__traceback_entriesS");
   u00035 : constant Version_32 := 16#61e81064#;
   pragma Export (C, u00035, "system__traceback__symbolicB");
   u00036 : constant Version_32 := 16#3e2e1203#;
   pragma Export (C, u00036, "system__traceback__symbolicS");
   u00037 : constant Version_32 := 16#179d7d28#;
   pragma Export (C, u00037, "ada__containersS");
   u00038 : constant Version_32 := 16#701f9d88#;
   pragma Export (C, u00038, "ada__exceptions__tracebackB");
   u00039 : constant Version_32 := 16#47e3d2a3#;
   pragma Export (C, u00039, "ada__exceptions__tracebackS");
   u00040 : constant Version_32 := 16#9111f9c1#;
   pragma Export (C, u00040, "interfacesS");
   u00041 : constant Version_32 := 16#b9ada65a#;
   pragma Export (C, u00041, "interfaces__cB");
   u00042 : constant Version_32 := 16#09d5a0e7#;
   pragma Export (C, u00042, "interfaces__cS");
   u00043 : constant Version_32 := 16#0978786d#;
   pragma Export (C, u00043, "system__bounded_stringsB");
   u00044 : constant Version_32 := 16#954ae884#;
   pragma Export (C, u00044, "system__bounded_stringsS");
   u00045 : constant Version_32 := 16#22b1fb99#;
   pragma Export (C, u00045, "system__crtlB");
   u00046 : constant Version_32 := 16#c12207f7#;
   pragma Export (C, u00046, "system__crtlS");
   u00047 : constant Version_32 := 16#71c7401b#;
   pragma Export (C, u00047, "system__dwarf_linesB");
   u00048 : constant Version_32 := 16#029d32b0#;
   pragma Export (C, u00048, "system__dwarf_linesS");
   u00049 : constant Version_32 := 16#5b4659fa#;
   pragma Export (C, u00049, "ada__charactersS");
   u00050 : constant Version_32 := 16#75913d83#;
   pragma Export (C, u00050, "ada__characters__handlingB");
   u00051 : constant Version_32 := 16#729cc5db#;
   pragma Export (C, u00051, "ada__characters__handlingS");
   u00052 : constant Version_32 := 16#cde9ea2d#;
   pragma Export (C, u00052, "ada__characters__latin_1S");
   u00053 : constant Version_32 := 16#e6d4fa36#;
   pragma Export (C, u00053, "ada__stringsS");
   u00054 : constant Version_32 := 16#9a8aed35#;
   pragma Export (C, u00054, "ada__strings__mapsB");
   u00055 : constant Version_32 := 16#879d83f1#;
   pragma Export (C, u00055, "ada__strings__mapsS");
   u00056 : constant Version_32 := 16#d55f7fbe#;
   pragma Export (C, u00056, "system__bit_opsB");
   u00057 : constant Version_32 := 16#2f4465a1#;
   pragma Export (C, u00057, "system__bit_opsS");
   u00058 : constant Version_32 := 16#189db6c4#;
   pragma Export (C, u00058, "system__unsigned_typesS");
   u00059 : constant Version_32 := 16#5c2ece6d#;
   pragma Export (C, u00059, "ada__strings__maps__constantsS");
   u00060 : constant Version_32 := 16#f9910acc#;
   pragma Export (C, u00060, "system__address_imageB");
   u00061 : constant Version_32 := 16#435b54a7#;
   pragma Export (C, u00061, "system__address_imageS");
   u00062 : constant Version_32 := 16#d7092338#;
   pragma Export (C, u00062, "system__img_address_32S");
   u00063 : constant Version_32 := 16#fa2982ba#;
   pragma Export (C, u00063, "system__img_address_64S");
   u00064 : constant Version_32 := 16#b9ea0573#;
   pragma Export (C, u00064, "system__img_unsS");
   u00065 : constant Version_32 := 16#20ec7aa3#;
   pragma Export (C, u00065, "system__ioB");
   u00066 : constant Version_32 := 16#7cf53ed2#;
   pragma Export (C, u00066, "system__ioS");
   u00067 : constant Version_32 := 16#e15ca368#;
   pragma Export (C, u00067, "system__mmapB");
   u00068 : constant Version_32 := 16#5d1b9a97#;
   pragma Export (C, u00068, "system__mmapS");
   u00069 : constant Version_32 := 16#367911c4#;
   pragma Export (C, u00069, "ada__io_exceptionsS");
   u00070 : constant Version_32 := 16#193b6ddb#;
   pragma Export (C, u00070, "system__mmap__os_interfaceB");
   u00071 : constant Version_32 := 16#f34495e5#;
   pragma Export (C, u00071, "system__mmap__os_interfaceS");
   u00072 : constant Version_32 := 16#7d07d9b0#;
   pragma Export (C, u00072, "system__mmap__unixS");
   u00073 : constant Version_32 := 16#861c956a#;
   pragma Export (C, u00073, "system__os_libB");
   u00074 : constant Version_32 := 16#dc62b743#;
   pragma Export (C, u00074, "system__os_libS");
   u00075 : constant Version_32 := 16#94d23d25#;
   pragma Export (C, u00075, "system__atomic_operations__test_and_setB");
   u00076 : constant Version_32 := 16#57acee8e#;
   pragma Export (C, u00076, "system__atomic_operations__test_and_setS");
   u00077 : constant Version_32 := 16#25d4b3b8#;
   pragma Export (C, u00077, "system__atomic_operationsS");
   u00078 : constant Version_32 := 16#553a519e#;
   pragma Export (C, u00078, "system__atomic_primitivesB");
   u00079 : constant Version_32 := 16#d8f6eff3#;
   pragma Export (C, u00079, "system__atomic_primitivesS");
   u00080 : constant Version_32 := 16#14fb286b#;
   pragma Export (C, u00080, "system__case_utilB");
   u00081 : constant Version_32 := 16#3c4f28f7#;
   pragma Export (C, u00081, "system__case_utilS");
   u00082 : constant Version_32 := 16#8b956324#;
   pragma Export (C, u00082, "system__case_util_nssB");
   u00083 : constant Version_32 := 16#87d84db7#;
   pragma Export (C, u00083, "system__case_util_nssS");
   u00084 : constant Version_32 := 16#256dbbe5#;
   pragma Export (C, u00084, "system__stringsB");
   u00085 : constant Version_32 := 16#7935c985#;
   pragma Export (C, u00085, "system__stringsS");
   u00086 : constant Version_32 := 16#8d759e14#;
   pragma Export (C, u00086, "system__object_readerB");
   u00087 : constant Version_32 := 16#ee235c84#;
   pragma Export (C, u00087, "system__object_readerS");
   u00088 : constant Version_32 := 16#b14bacb0#;
   pragma Export (C, u00088, "system__val_lliS");
   u00089 : constant Version_32 := 16#7d4c7c5b#;
   pragma Export (C, u00089, "system__val_lluS");
   u00090 : constant Version_32 := 16#0d1904b9#;
   pragma Export (C, u00090, "system__val_utilB");
   u00091 : constant Version_32 := 16#0e1c2bbe#;
   pragma Export (C, u00091, "system__val_utilS");
   u00092 : constant Version_32 := 16#382ef1e7#;
   pragma Export (C, u00092, "system__exception_tracesB");
   u00093 : constant Version_32 := 16#0e2fa0fb#;
   pragma Export (C, u00093, "system__exception_tracesS");
   u00094 : constant Version_32 := 16#fd158a37#;
   pragma Export (C, u00094, "system__wch_conB");
   u00095 : constant Version_32 := 16#3bb4eafe#;
   pragma Export (C, u00095, "system__wch_conS");
   u00096 : constant Version_32 := 16#5c289972#;
   pragma Export (C, u00096, "system__wch_stwB");
   u00097 : constant Version_32 := 16#16a5c6ff#;
   pragma Export (C, u00097, "system__wch_stwS");
   u00098 : constant Version_32 := 16#7cd63de5#;
   pragma Export (C, u00098, "system__wch_cnvB");
   u00099 : constant Version_32 := 16#3d74208e#;
   pragma Export (C, u00099, "system__wch_cnvS");
   u00100 : constant Version_32 := 16#e538de43#;
   pragma Export (C, u00100, "system__wch_jisB");
   u00101 : constant Version_32 := 16#88c342a4#;
   pragma Export (C, u00101, "system__wch_jisS");
   u00102 : constant Version_32 := 16#d61fa080#;
   pragma Export (C, u00102, "system__os_primitivesB");
   u00103 : constant Version_32 := 16#e54aac6b#;
   pragma Export (C, u00103, "system__os_primitivesS");
   u00104 : constant Version_32 := 16#75266e31#;
   pragma Export (C, u00104, "system__c_timeB");
   u00105 : constant Version_32 := 16#0c19ab29#;
   pragma Export (C, u00105, "system__c_timeS");
   u00106 : constant Version_32 := 16#e91b7be9#;
   pragma Export (C, u00106, "system__os_constantsS");
   u00107 : constant Version_32 := 16#08e5adbf#;
   pragma Export (C, u00107, "ada__command_lineB");
   u00108 : constant Version_32 := 16#3cdef8c9#;
   pragma Export (C, u00108, "ada__command_lineS");
   u00109 : constant Version_32 := 16#6e6e3f5b#;
   pragma Export (C, u00109, "ada__streamsB");
   u00110 : constant Version_32 := 16#bd793559#;
   pragma Export (C, u00110, "ada__streamsS");
   u00111 : constant Version_32 := 16#a201b8c5#;
   pragma Export (C, u00111, "ada__strings__text_buffersB");
   u00112 : constant Version_32 := 16#a7cfd09b#;
   pragma Export (C, u00112, "ada__strings__text_buffersS");
   u00113 : constant Version_32 := 16#8b7604c4#;
   pragma Export (C, u00113, "ada__strings__utf_encodingB");
   u00114 : constant Version_32 := 16#c9e86997#;
   pragma Export (C, u00114, "ada__strings__utf_encodingS");
   u00115 : constant Version_32 := 16#bb780f45#;
   pragma Export (C, u00115, "ada__strings__utf_encoding__stringsB");
   u00116 : constant Version_32 := 16#b85ff4b6#;
   pragma Export (C, u00116, "ada__strings__utf_encoding__stringsS");
   u00117 : constant Version_32 := 16#d1d1ed0b#;
   pragma Export (C, u00117, "ada__strings__utf_encoding__wide_stringsB");
   u00118 : constant Version_32 := 16#5678478f#;
   pragma Export (C, u00118, "ada__strings__utf_encoding__wide_stringsS");
   u00119 : constant Version_32 := 16#c2b98963#;
   pragma Export (C, u00119, "ada__strings__utf_encoding__wide_wide_stringsB");
   u00120 : constant Version_32 := 16#d7af3358#;
   pragma Export (C, u00120, "ada__strings__utf_encoding__wide_wide_stringsS");
   u00121 : constant Version_32 := 16#df45aed8#;
   pragma Export (C, u00121, "ada__tagsB");
   u00122 : constant Version_32 := 16#99822aba#;
   pragma Export (C, u00122, "ada__tagsS");
   u00123 : constant Version_32 := 16#3548d972#;
   pragma Export (C, u00123, "system__htableB");
   u00124 : constant Version_32 := 16#636e9176#;
   pragma Export (C, u00124, "system__htableS");
   u00125 : constant Version_32 := 16#1f1abe38#;
   pragma Export (C, u00125, "system__string_hashB");
   u00126 : constant Version_32 := 16#c42b1109#;
   pragma Export (C, u00126, "system__string_hashS");
   u00127 : constant Version_32 := 16#44f765f3#;
   pragma Export (C, u00127, "system__put_imagesB");
   u00128 : constant Version_32 := 16#f2a8455f#;
   pragma Export (C, u00128, "system__put_imagesS");
   u00129 : constant Version_32 := 16#22b9eb9f#;
   pragma Export (C, u00129, "ada__strings__text_buffers__utilsB");
   u00130 : constant Version_32 := 16#89062ac3#;
   pragma Export (C, u00130, "ada__strings__text_buffers__utilsS");
   u00131 : constant Version_32 := 16#2d69612d#;
   pragma Export (C, u00131, "ada__streams__stream_ioB");
   u00132 : constant Version_32 := 16#44ae819b#;
   pragma Export (C, u00132, "ada__streams__stream_ioS");
   u00133 : constant Version_32 := 16#1cacf006#;
   pragma Export (C, u00133, "interfaces__c_streamsB");
   u00134 : constant Version_32 := 16#ecfa876a#;
   pragma Export (C, u00134, "interfaces__c_streamsS");
   u00135 : constant Version_32 := 16#5de653db#;
   pragma Export (C, u00135, "system__communicationB");
   u00136 : constant Version_32 := 16#adcd0543#;
   pragma Export (C, u00136, "system__communicationS");
   u00137 : constant Version_32 := 16#a94e7662#;
   pragma Export (C, u00137, "system__file_ioB");
   u00138 : constant Version_32 := 16#84f89cdb#;
   pragma Export (C, u00138, "system__file_ioS");
   u00139 : constant Version_32 := 16#7598b591#;
   pragma Export (C, u00139, "ada__finalizationS");
   u00140 : constant Version_32 := 16#d00f339c#;
   pragma Export (C, u00140, "system__finalization_rootB");
   u00141 : constant Version_32 := 16#e8cbf749#;
   pragma Export (C, u00141, "system__finalization_rootS");
   u00142 : constant Version_32 := 16#8e328749#;
   pragma Export (C, u00142, "system__finalization_primitivesB");
   u00143 : constant Version_32 := 16#64e3a357#;
   pragma Export (C, u00143, "system__finalization_primitivesS");
   u00144 : constant Version_32 := 16#fae11091#;
   pragma Export (C, u00144, "system__os_locksS");
   u00145 : constant Version_32 := 16#880c7e1a#;
   pragma Export (C, u00145, "system__file_control_blockS");
   u00146 : constant Version_32 := 16#c7620b41#;
   pragma Export (C, u00146, "ada__text_ioB");
   u00147 : constant Version_32 := 16#2e7275c8#;
   pragma Export (C, u00147, "ada__text_ioS");
   u00148 : constant Version_32 := 16#ff30079a#;
   pragma Export (C, u00148, "silver_output_profileB");
   u00149 : constant Version_32 := 16#2023f6e5#;
   pragma Export (C, u00149, "silver_output_profileS");
   u00150 : constant Version_32 := 16#062cd895#;
   pragma Export (C, u00150, "silver_integer_imageS");
   u00151 : constant Version_32 := 16#0c7bc18e#;
   pragma Export (C, u00151, "silver_scalarsS");
   u00152 : constant Version_32 := 16#10201866#;
   pragma Export (C, u00152, "silver_integer_literalsB");
   u00153 : constant Version_32 := 16#8cfec589#;
   pragma Export (C, u00153, "silver_integer_literalsS");
   u00154 : constant Version_32 := 16#83571fa6#;
   pragma Export (C, u00154, "system__assertionsB");
   u00155 : constant Version_32 := 16#c4b4b606#;
   pragma Export (C, u00155, "system__assertionsS");
   u00156 : constant Version_32 := 16#8b2c6428#;
   pragma Export (C, u00156, "ada__assertionsB");
   u00157 : constant Version_32 := 16#cc3ec2fd#;
   pragma Export (C, u00157, "ada__assertionsS");
   u00158 : constant Version_32 := 16#c773cad5#;
   pragma Export (C, u00158, "silver_profileB");
   u00159 : constant Version_32 := 16#5649a64c#;
   pragma Export (C, u00159, "silver_profileS");
   u00160 : constant Version_32 := 16#643525bd#;
   pragma Export (C, u00160, "silver_length_intervalsB");
   u00161 : constant Version_32 := 16#3dddb734#;
   pragma Export (C, u00161, "silver_length_intervalsS");
   u00162 : constant Version_32 := 16#8e62dfb5#;
   pragma Export (C, u00162, "silver_path_factsS");
   u00163 : constant Version_32 := 16#35019943#;
   pragma Export (C, u00163, "silver_namesB");
   u00164 : constant Version_32 := 16#f011e7df#;
   pragma Export (C, u00164, "silver_namesS");
   u00165 : constant Version_32 := 16#f0458332#;
   pragma Export (C, u00165, "silver_output_lexicalB");
   u00166 : constant Version_32 := 16#47790207#;
   pragma Export (C, u00166, "silver_output_lexicalS");
   u00167 : constant Version_32 := 16#09f88a89#;
   pragma Export (C, u00167, "silver_scalar_expressionsB");
   u00168 : constant Version_32 := 16#fec0b7c3#;
   pragma Export (C, u00168, "silver_scalar_expressionsS");
   u00169 : constant Version_32 := 16#0db70d7c#;
   pragma Export (C, u00169, "silver_scalar_literalsB");
   u00170 : constant Version_32 := 16#4aeb4770#;
   pragma Export (C, u00170, "silver_scalar_literalsS");
   u00171 : constant Version_32 := 16#ca878138#;
   pragma Export (C, u00171, "system__concat_2B");
   u00172 : constant Version_32 := 16#574cba6a#;
   pragma Export (C, u00172, "system__concat_2S");
   u00173 : constant Version_32 := 16#8218f1df#;
   pragma Export (C, u00173, "system__img_fixed_64S");
   u00174 : constant Version_32 := 16#27732c71#;
   pragma Export (C, u00174, "system__arith_64B");
   u00175 : constant Version_32 := 16#134523ab#;
   pragma Export (C, u00175, "system__arith_64S");
   u00176 : constant Version_32 := 16#6f0615c9#;
   pragma Export (C, u00176, "system__exn_lliS");
   u00177 : constant Version_32 := 16#eeeda2c4#;
   pragma Export (C, u00177, "system__img_utilB");
   u00178 : constant Version_32 := 16#95ae6d24#;
   pragma Export (C, u00178, "system__img_utilS");
   u00179 : constant Version_32 := 16#be6f5d2e#;
   pragma Export (C, u00179, "system__strings__stream_opsB");
   u00180 : constant Version_32 := 16#9a9c0b11#;
   pragma Export (C, u00180, "system__strings__stream_opsS");
   u00181 : constant Version_32 := 16#72726776#;
   pragma Export (C, u00181, "system__stream_attributesB");
   u00182 : constant Version_32 := 16#5324c4c7#;
   pragma Export (C, u00182, "system__stream_attributesS");
   u00183 : constant Version_32 := 16#c027a94e#;
   pragma Export (C, u00183, "system__stream_attributes__xdrB");
   u00184 : constant Version_32 := 16#35ff530d#;
   pragma Export (C, u00184, "system__stream_attributes__xdrS");
   u00185 : constant Version_32 := 16#218516f1#;
   pragma Export (C, u00185, "system__fat_fltS");
   u00186 : constant Version_32 := 16#07b71ffc#;
   pragma Export (C, u00186, "system__fat_lfltS");
   u00187 : constant Version_32 := 16#7d67b116#;
   pragma Export (C, u00187, "system__fat_llfS");
   u00188 : constant Version_32 := 16#a56a70fa#;
   pragma Export (C, u00188, "system__memoryB");
   u00189 : constant Version_32 := 16#fa235587#;
   pragma Export (C, u00189, "system__memoryS");

   --  BEGIN ELABORATION ORDER
   --  ada%s
   --  ada.characters%s
   --  ada.characters.latin_1%s
   --  interfaces%s
   --  system%s
   --  system.atomic_operations%s
   --  system.case_util_nss%s
   --  system.case_util_nss%b
   --  system.io%s
   --  system.io%b
   --  system.parameters%s
   --  system.parameters%b
   --  system.crtl%s
   --  system.crtl%b
   --  interfaces.c_streams%s
   --  interfaces.c_streams%b
   --  system.storage_elements%s
   --  system.img_address_32%s
   --  system.img_address_64%s
   --  system.stack_checking%s
   --  system.stack_checking%b
   --  system.string_hash%s
   --  system.string_hash%b
   --  system.htable%s
   --  system.htable%b
   --  system.strings%s
   --  system.strings%b
   --  system.traceback_entries%s
   --  system.traceback_entries%b
   --  system.unsigned_types%s
   --  system.wch_con%s
   --  system.wch_con%b
   --  system.wch_jis%s
   --  system.wch_jis%b
   --  system.wch_cnv%s
   --  system.wch_cnv%b
   --  system.concat_2%s
   --  system.concat_2%b
   --  system.exn_lli%s
   --  system.img_int%s
   --  system.img_uns%s
   --  system.img_util%s
   --  system.img_util%b
   --  system.traceback%s
   --  system.traceback%b
   --  ada.characters.handling%s
   --  system.atomic_operations.test_and_set%s
   --  system.case_util%s
   --  system.os_lib%s
   --  system.secondary_stack%s
   --  system.standard_library%s
   --  ada.exceptions%s
   --  system.exceptions_debug%s
   --  system.exceptions_debug%b
   --  system.soft_links%s
   --  system.val_util%s
   --  system.val_util%b
   --  system.val_llu%s
   --  system.val_lli%s
   --  system.wch_stw%s
   --  system.wch_stw%b
   --  ada.exceptions.last_chance_handler%s
   --  ada.exceptions.last_chance_handler%b
   --  ada.exceptions.traceback%s
   --  ada.exceptions.traceback%b
   --  system.address_image%s
   --  system.address_image%b
   --  system.bit_ops%s
   --  system.bit_ops%b
   --  system.bounded_strings%s
   --  system.bounded_strings%b
   --  system.case_util%b
   --  system.exception_table%s
   --  system.exception_table%b
   --  ada.containers%s
   --  ada.io_exceptions%s
   --  ada.strings%s
   --  ada.strings.maps%s
   --  ada.strings.maps%b
   --  ada.strings.maps.constants%s
   --  interfaces.c%s
   --  interfaces.c%b
   --  system.atomic_primitives%s
   --  system.atomic_primitives%b
   --  system.exceptions%s
   --  system.exceptions.machine%s
   --  system.exceptions.machine%b
   --  ada.characters.handling%b
   --  system.atomic_operations.test_and_set%b
   --  system.exception_traces%s
   --  system.exception_traces%b
   --  system.memory%s
   --  system.memory%b
   --  system.mmap%s
   --  system.mmap.os_interface%s
   --  system.mmap%b
   --  system.mmap.unix%s
   --  system.mmap.os_interface%b
   --  system.object_reader%s
   --  system.object_reader%b
   --  system.dwarf_lines%s
   --  system.dwarf_lines%b
   --  system.os_lib%b
   --  system.secondary_stack%b
   --  system.soft_links.initialize%s
   --  system.soft_links.initialize%b
   --  system.soft_links%b
   --  system.standard_library%b
   --  system.traceback.symbolic%s
   --  system.traceback.symbolic%b
   --  ada.exceptions%b
   --  ada.assertions%s
   --  ada.assertions%b
   --  ada.command_line%s
   --  ada.command_line%b
   --  ada.strings.utf_encoding%s
   --  ada.strings.utf_encoding%b
   --  ada.strings.utf_encoding.strings%s
   --  ada.strings.utf_encoding.strings%b
   --  ada.strings.utf_encoding.wide_strings%s
   --  ada.strings.utf_encoding.wide_strings%b
   --  ada.strings.utf_encoding.wide_wide_strings%s
   --  ada.strings.utf_encoding.wide_wide_strings%b
   --  ada.tags%s
   --  ada.tags%b
   --  ada.strings.text_buffers%s
   --  ada.strings.text_buffers%b
   --  ada.strings.text_buffers.utils%s
   --  ada.strings.text_buffers.utils%b
   --  system.arith_64%s
   --  system.arith_64%b
   --  system.fat_flt%s
   --  system.fat_lflt%s
   --  system.fat_llf%s
   --  system.os_constants%s
   --  system.c_time%s
   --  system.c_time%b
   --  system.os_locks%s
   --  system.finalization_primitives%s
   --  system.finalization_primitives%b
   --  system.os_primitives%s
   --  system.os_primitives%b
   --  system.put_images%s
   --  system.put_images%b
   --  ada.streams%s
   --  ada.streams%b
   --  system.communication%s
   --  system.communication%b
   --  system.file_control_block%s
   --  system.finalization_root%s
   --  system.finalization_root%b
   --  ada.finalization%s
   --  system.file_io%s
   --  system.file_io%b
   --  ada.streams.stream_io%s
   --  ada.streams.stream_io%b
   --  system.stream_attributes%s
   --  system.stream_attributes.xdr%s
   --  system.stream_attributes.xdr%b
   --  system.stream_attributes%b
   --  ada.calendar%s
   --  ada.calendar%b
   --  ada.text_io%s
   --  ada.text_io%b
   --  system.assertions%s
   --  system.assertions%b
   --  system.img_fixed_64%s
   --  system.strings.stream_ops%s
   --  system.strings.stream_ops%b
   --  silver_path_facts%s
   --  silver_length_intervals%s
   --  silver_length_intervals%b
   --  silver_profile%s
   --  silver_profile%b
   --  silver_integer_literals%s
   --  silver_integer_literals%b
   --  silver_output_lexical%s
   --  silver_output_lexical%b
   --  silver_names%s
   --  silver_names%b
   --  silver_scalar_literals%s
   --  silver_scalar_literals%b
   --  silver_scalars%s
   --  silver_integer_image%s
   --  silver_scalar_expressions%s
   --  silver_scalar_expressions%b
   --  silver_output_profile%s
   --  silver_output_profile%b
   --  probe_main%b
   --  END ELABORATION ORDER

end ada_main;
