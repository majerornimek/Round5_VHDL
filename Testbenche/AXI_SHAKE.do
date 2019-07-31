onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/rst
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/clk
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_Full
add wave -noupdate -radix hexadecimal /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_din
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_wr_en
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_Empty
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_dout
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FIFO_rd_en
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/start_module
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/reset_module
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/done_module
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/op_module
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/op_selected
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_Full
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_Din
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_wr_en
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_Empty
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_Dout
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_FIFO_rd_en
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_pointer
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_pointer_max
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/output_pointer
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/output_pointer_max
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SHAKE_input_pointer
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SHAKE_input_pointer_max
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SHAKE_output_pointer
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SHAKE_output_pointer_max
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Extended_SHAKE_output_pointer
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_sigma
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_sk
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_rho
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/data_ready
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyB_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyR_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Message_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/ctV_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FirstPart_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SecondPart_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Dec_Msg_tmp
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyA_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyB_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyR_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Message_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/ctV_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Output_count
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/Out_saved
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyA_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyB_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/PolyR_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/ctV_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/FirstPart_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/SecondPart_poly
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/S_Reset
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin_read
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin_empty
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout_full
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout_write
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/odata
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/idata
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/pass_data_to_S_FIFO
add wave -noupdate -radix unsigned -childformat {{/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(7) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(6) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(5) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(4) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(3) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(2) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(1) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(0) -radix unsigned}} -subitemconfig {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(7) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(6) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(5) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(4) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(3) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(2) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(1) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND(0) {-height 15 -radix unsigned}} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/COMMAND
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/RECIVED_CMD
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_sigma_cmd
add wave -noupdate -radix unsigned -childformat {{/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(7) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(6) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(5) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(4) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(3) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(2) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(1) -radix unsigned} {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(0) -radix unsigned}} -subitemconfig {/round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(7) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(6) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(5) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(4) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(3) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(2) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(1) {-height 15 -radix unsigned} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd(0) {-height 15 -radix unsigned}} /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_B_cmd
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_rho_cmd
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_msg_cmd
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_sk_cmd
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_U_cmd
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/input_V_cmd
add wave -noupdate -divider Arithm
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/PolyA
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/PolyB
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/PolyR
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Message
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/ctV
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/clk
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Start
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Reset
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Operation
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Done
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/FirstPart
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/SecondPart
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Dec_Msg
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Rounded_e1
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Rounded_e2
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Rounded_d1
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Poly_2_round
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/polyA_2_mul
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/PolyB_ext
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/PolyR_ext
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_start
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_type
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_rst
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_done
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_res
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/mul_res_short
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/unpacked_v
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/arithm_result
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/arithm_result_q
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/rounding_const
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/FSM
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/AddedMessage
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Reversed_Messsage
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/Ordered_Message
add wave -noupdate -divider SHAKE
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/arit/p_bits_poly_memory_register_1
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/HS
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/rst
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/clk
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/src_ready
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/src_read
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/dst_ready
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/dst_write
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/din
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/dout
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/ein
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/final_segment
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/sel_xor
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/sel_final
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/wr_state
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/en_ctr
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/c
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/d
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/en_len
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/en_output_len
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/ld_rdctr
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/en_rdctr
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/sel_piso
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/last_block
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/wr_piso
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/spos
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/sel_dec_size
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/clr_len
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/last_word
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/capacity
add wave -noupdate -radix unsigned /round5_axi_wrapper_v4_packed_with_shake_tb/uut/kecc/version
add wave -noupdate -divider SFIFO_out
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/fifo_mode
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/fifo_style
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/depth
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/log2depth
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/n
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/clk
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/rst
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/write
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/read
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/din
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/dout
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/full
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/empty
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/readpointer
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/writepointer
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/bytecounter
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/wr_en_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/fifo_full_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/fifo_empty_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/read_ok
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/read_address
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoout/dataout
add wave -noupdate -divider SFIFO_in
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/fifo_mode
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/fifo_style
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/depth
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/log2depth
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/n
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/clk
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/rst
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/write
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/read
add wave -noupdate -radix hexadecimal /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/din
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/dout
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/full
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/empty
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/readpointer
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/writepointer
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/bytecounter
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/wr_en_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/fifo_full_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/fifo_empty_s
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/read_ok
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/read_address
add wave -noupdate /round5_axi_wrapper_v4_packed_with_shake_tb/uut/fifoin/dataout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {85 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {941 ps}