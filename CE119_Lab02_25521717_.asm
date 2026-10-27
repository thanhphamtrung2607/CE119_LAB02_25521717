.data

scores: .word 2,10,4,5,9,1,3,9,2,5,0,10
n: .word 12
grade_tab: .byte 0,0,0,0,1,1,1,2,2,3,3
           .align 2
hist: .word 0,0,0,0
s_min: .asciiz "min= "
s_max: .asciiz " max= "
s_g0: .asciiz "g0= "
s_g1: .asciiz " g1= "
s_g2: .asciiz " g2= "
s_g3: .asciiz " g3= "
newline: .asciiz"\n"


# main: chuong trinh chinh
# Thanh ghi su dung:
#   $s0 = min (nhan tu $v0 cua stats)
#   $s1 = max (nhan tu $v1 cua stats)
#   $s2 = dia chi hist, dung de in g0..g3
#   $a0-$a3 = tham so cho stats, histogram va syscall in
#   $v0 = ma dich vu syscall (1: in so, 4: in chuoi, 10: thoat)

.text
.globl main
main:


# goi stats
la $a0, scores
lw $a1, n
jal stats
move $s0, $v0
move $s1, $v1


#goi hístogram
la $a0, scores
lw $a1, n
la $a2, grade_tab
la $a3, hist
jal histogram

#goi draw_hist
la $a0, hist        
li $a1, 4           
jal draw_hist 

li $v0, 4
la $a0, s_min
syscall
li $v0,1
move $a0, $s0
syscall
li $v0, 4
la $a0, s_max
syscall
li $v0, 1
move $a0, $s1
syscall
li $v0, 4
la $a0, newline
syscall

la $s2, hist
li $v0, 4
la $a0, s_g0
syscall
li $v0, 1
lw $a0, 0($s2)
syscall
li $v0, 4
la $a0, s_g1
syscall
li $v0, 1
lw $a0, 4($s2)
syscall
li $v0,4
la $a0, s_g2
syscall
li $v0,1
lw $a0, 8($s2)
syscall
li $v0,4
la $a0,s_g3
syscall
li $v0,1
lw $a0, 12($s2)
syscall
li $v0,4
la $a0, newline
syscall
li $v0, 10
syscall

stats:
# stats: tim gia tri nho nhat va lon nhat cua mang word
# Tham so:
#   $a0 = dia chi mang word
#   $a1 = n (so phan tu, n >= 1)
# Gia tri tra ve:
#   $v0 = gia tri nho nhat
#   $v1 = gia tri lon nhat
# Thanh ghi su dung:
#   $t0 = phan tu dang xet
#   $t1 = ket qua so sanh slt (0 hoac 1)
#   $a0, $a1 bi thay doi (con tro chay, bo dem con lai)
# Ghi chu: la thu tuc la (khong jal nen khong luu $ra),  mot luot duyet, khong ghi bo nho

lw $v0, 0($a0)
move $v1, $v0
addi $a0, $a0, 4
addi $a1, $a1, -1

loop:
beq $a1, $zero, done
lw $t0, 0($a0)
slt $t1, $t0, $v0
beq $t1, $zero, out_max
move $v0, $t0
out_max:
slt $t1, $v1, $t0
beq $t1, $zero, next
move $v1, $t0
next:
addi $a0, $a0, 4
addi $a1, $a1, -1
j loop
done: 
jr $ra

# histogram: dem so diem trong tung nhom, hist[grade_tab[s]]++
# Tham so:
#   $a0 = dia chi mang diem (word)
#   $a1 = n (so phan tu)
#   $a2 = dia chi grade_tab (mang byte, 11 phan tu)
#   $a3 = dia chi hist (mang 4 word)
# Gia tri tra ve: khong co (ket qua nam trong mang hist)
# Thanh ghi su dung:
#   $t0 = diem s dang xet
#   $t1 = dia chi grade_tab[s]
#   $t2 = chi so nhom, sau do la dia chi hist[nhom]
#   $t3 = gia tri bo dem hist[nhom]
#   $a0, $a1 bi thay doi; $a2, $a3 khong doi
# Ghi chu: la thu tuc la, tra bang bang lbu, ghi bo nho (sw),vao hist. Gia dinh moi diem nam trong 0..10
#          vao hist. Gia dinh moi diem nam trong 0..10.

histogram:
hi_loop:
beq $a1, $zero, hi_done
lw $t0, 0($a0)
add $t1, $a2, $t0  
lbu $t2, 0($t1)
sll $t2, $t2, 2
add $t2, $t2, $a3
lw $t3, 0($t2)
addi $t3, $t3, 1
sw $t3, 0($t2)
addi $a0, $a0, 4
addi $a1, $a1, -1
j hi_loop
hi_done:
jr $ra

# draw_hist: ve bieu do cot ngang bang ky tu '|'
# Tham so:
#   $a0 = dia chi mang hist
#   $a1 = so nhom 
# Gia tri tra ve: khong co
# Thanh ghi su dung:
#   $t0 = con tro toi hist[g]
#   $t1 = so nhom
#   $t2 = chi so nhom g
#   $t3 = bo dem so ky tu '|' con phai in
#   $v0, $a0 = ma dich vu va tham so cho syscall (bi thay doi)
# Ghi chu: la thu tuc la; phai chep $a0, $a1 sang $t truoc vi moi syscall in deu ghi de $a0.
draw_hist:
    move $t0, $a0             
    move $t1, $a1             
    li   $t2, 0                
dh_group:
    beq  $t2, $t1, dh_done     

    li   $v0, 11            
    li   $a0, 'g'
    syscall
    li   $v0, 1                
    move $a0, $t2
    syscall
    li   $v0, 11              
    li   $a0, ':'
    syscall
    li   $v0, 11              
    li   $a0, ' '
    syscall

    lw   $t3, 0($t0)          
dh_bar:
    beq  $t3, $zero, dh_endl   
    li   $v0, 11
    li   $a0, '|'
    syscall
    addi $t3, $t3, -1
    j    dh_bar
dh_endl:
    li   $v0, 11             
    li   $a0, 10
    syscall

    addi $t0, $t0, 4           
    addi $t2, $t2, 1
    j    dh_group
dh_done:
    jr   $ra




