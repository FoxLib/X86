#include "main.h"

byte Main::fetch_byte() {
    return readb(ip++);
}

dword Main::fetch_dword() {

    dword t = readd(ip);
    ip += 4;
    return t;
}

void Main::push(dword data) {

    sp = (sp - 1) & 0x3ff;
    stack[sp] = data;
}

dword Main::pop() {

    dword data = stack[sp];
    sp = (sp + 1) & 0x3ff;
    return data;
}

// Регистр r0 - всегда 0
dword Main::get_reg(int n) {
    return regs[ n & 255 ];
}

void Main::put_reg(int n, dword v) {
    regs[ n & 255 ] = v;
}

// Арифметико-логика
dword Main::grp(dword a, dword b, int instr) {

    dword r;
    dword ci = 0x100000000;
    dword si = 0x080000000;
    dword mi = 0x0FFFFFFFF;

    a &= mi;
    b &= mi;

    switch (instr) {

        /* ADD */ case 0: r = (a + b); break;
        /* ADC */ case 1: r = (a + b) + cf; break;
        /* SUB */ case 2: r = (a - b); break;
        /* SBC */ case 3: r = (a - b) - cf; break;
        /* AND */ case 4: r = (a & b); break;
        /* XOR */ case 5: r = (a ^ b); break;
        /* OR  */ case 6: r = (a | b); break;
        /* CMP */ case 7: r = (a - b); break;
    }

    switch (instr) {

        // ADD, ADC
        case 0: case 1:

            of = ((a ^ b ^ si) & (a ^ r)) & si ? 1 : 0;
            break;

        // SUB, SBC, CMP
        case 2: case 3: case 7:

            of = ((a ^ b) & (a ^ r)) & si ? 1 : 0;
            break;

        default: of = 0;
    }

    cf = (r & ci) ? 1 : 0;
    sf = (r & si) ? 1 : 0;
    zf = (r & mi) == 0 ? 1 : 0;

    return r & mi;
}

// Сдвиг на 0 невозможен
dword Main::sft(dword a, dword b, int op) {

    int i;

    dword si = 0x080000000;
    dword mi = 0x0FFFFFFFF;

    if (b > 32) b = 32;
    if (b == 0) return a;

    a &= mi;

    switch (op & 3) {

        // SHR
        case 0:

            for (i = 0; i < b; i++) {

                cf = a & 1;
                a  >>= 1;
            }

            break;

        // SAR
        case 1:

            for (i = 0; i < b; i++) {

                cf = a & 1;
                a  = (a & si ? si : 0) | (a >> 1);
            }

            break;

        // SHL
        case 2:

            cf  = (a & (1 << (32-b))) ? 1 : 0;
            a <<= b;
            break;

        // ROR
        case 3:

            for (i = 0; i < b; i++) {

                cf = a & 1;
                a >>= 1;
                if (cf) a |= si;
            }

            break;
    }

    sf = (a & si) ? 1 : 0;
    zf = (a & mi) == 0 ? 1 : 0;

    return a & mi;
}

// Исполнение инструкции
int Main::step() {

    dword opcode = fetch_byte();
    dword ra, rb, rc;
    dword u32;

    signed char s8;

    // Стандартный средний цикл
    int cycle = 3;

    switch (opcode) {

        case 0x00: { // MOV ra, rb

            rb = fetch_byte();
            ra = fetch_byte();
            put_reg(ra, get_reg(rb));
            cycle += 3;
            break;
        }
        case 0x01: { // MOV ra, u32

            ra  = fetch_byte();
            u32 = fetch_dword();
            put_reg(ra, u32);
            cycle += 6;
            break;
        }
        case 0x02: { // MOVU ra, u8

            ra  = fetch_byte();
            u32 = fetch_byte();
            put_reg(ra, u32);
            cycle += 3;
            break;
        }
        case 0x03: { // MOVS ra, s8

            ra  = fetch_byte();
            u32 = fetch_byte();
            put_reg(ra, (u32 & 0x80) ? 0xFFFFFF00 | u32 : u32);
            cycle += 3;
            break;
        }
        case 0x04: { // MOVB ra, [rb]

            rb = fetch_byte();
            ra = fetch_byte();
            put_reg(ra, readb(get_reg(rb)));
            cycle += 4;
            break;
        }
        case 0x05: { // MOVD ra, [rb]

            rb = fetch_byte();
            ra = fetch_byte();
            put_reg(ra, readd(get_reg(rb)));
            cycle += 7;
            break;
        }
        case 0x06: { // MOVB [rb], ra

            rb = fetch_byte();
            ra = fetch_byte();
            writeb(get_reg(rb), get_reg(ra));
            cycle += 5;
            break;
        }
        case 0x07: { // MOVD [rb], ra

            rb = fetch_byte();
            ra = fetch_byte();
            writed(get_reg(rb), get_reg(ra));
            cycle += 8;
            break;
        }
        case 0x08: { // PUSH ra

            ra = fetch_byte();
            push(get_reg(ra));
            cycle = 3;
            break;
        }
        case 0x09: { // POP ra

            ra = fetch_byte();
            put_reg(ra, pop());
            cycle = 2;
            break;
        }
        case 0x0A: { // PUSH u8

            u32 = fetch_byte();
            push(u32);
            cycle = 2;
            break;
        }
        case 0x0B: { // PUSH u32

            u32 = fetch_dword();
            push(u32);
            cycle = 5;
            break;
        }
        case 0x0C: { // PUSH ra-rb

            ra = fetch_byte();
            rb = fetch_byte();
            for (int i = ra; i <= rb; i++) {
                push(get_reg(i));
            }
            cycle = 4+(rb-ra);
            break;
        }
        case 0x0D: { // POP rb-ra

            rb = fetch_byte();
            ra = fetch_byte();
            for (int i = (int) rb; i >= (int) ra; i--) {
                put_reg(i, pop());
            }
            cycle = 4+(rb-ra);
            break;
        }
        case 0x0E: { // MOV ra, [sp+s8]

            s8 = fetch_byte();
            ra = fetch_byte();
            put_reg(ra, stack[ (sp+s8) & 0x3ff ]);
            cycle = 3;
            break;
        }
        case 0x0F: { // MOV [sp+s8], ra

            ra = fetch_byte();
            s8 = fetch_byte();
            stack[ (sp+s8) & 0x3ff ] = get_reg(ra);
            cycle = 3;
            break;
        }
        case 0x10: { // JMP s16

            u32  = fetch_byte();
            u32 += 256*fetch_byte();
            ip  += (signed short) u32;
            cycle = 3;
            break;
        }
        case 0x11: { // JMP ra

            ra = fetch_byte();
            ip = get_reg(ra);
            cycle = 3;
            break;
        }
        case 0x12: { // CALL s16

            u32  = fetch_byte();
            u32 += 256*fetch_byte();
            push(ip);
            ip  += (signed short) u32;
            cycle = 3;
            break;
        }
        case 0x13: { // CALL ra

            ra = fetch_byte();
            push(ip);
            ip = get_reg(ra);
            cycle = 3;
            break;
        }
        case 0x14: { // RET

            ip = pop();
            cycle = 2;
            break;
        }
        case 0x15: { // RET imm

            u32 = fetch_byte();
            ip  = pop();
            sp  = (sp + u32) & 0x3ff;
            cycle = 3;
            break;
        }
        case 0x16: { // MOV ra, sp

            ra = fetch_byte();
            put_reg(ra, sp);
            cycle = 2;
            break;
        }
        case 0x17: { // MOV sp, ra

            ra = fetch_byte();
            sp = get_reg(ra);
            cycle = 3;
            break;
        }
        // JMP <ccc> s16
        case 0x18: case 0x19: case 0x1A: case 0x1B:
        case 0x1C: case 0x1D: case 0x1E: case 0x1F: {

            s8 = fetch_byte();
            cycle = 1;

            switch (opcode & 7) {

                case 0: if (!zf) { ip += s8; cycle = 2; } break;
                case 1: if ( zf) { ip += s8; cycle = 2; } break;
                case 2: if (!cf) { ip += s8; cycle = 2; } break;
                case 3: if ( cf) { ip += s8; cycle = 2; } break;
                case 4: if (!sf) { ip += s8; cycle = 2; } break;
                case 5: if ( sf) { ip += s8; cycle = 2; } break;
                case 6: if (!of) { ip += s8; cycle = 2; } break;
                case 7: if ( of) { ip += s8; cycle = 2; } break;
            }

            break;
        }

        // <alu> ra, rb, rc
        case 0x20: case 0x21: case 0x22: case 0x23:
        case 0x24: case 0x25: case 0x26: case 0x27: {

            rc  = get_reg(fetch_byte());
            rb  = get_reg(fetch_byte());
            ra  = fetch_byte();
            u32 = grp(rb, rc, opcode & 7);
            if ((opcode & 7) != 7) put_reg(ra, u32);
            cycle = 4;
            break;
        }

        // <alu> ra, u32
        case 0x28: case 0x29: case 0x2A: case 0x2B:
        case 0x2C: case 0x2D: case 0x2E: case 0x2F: {

            ra  = fetch_byte();
            u32 = fetch_dword();
            u32 = grp(get_reg(ra), u32, opcode & 7);
            if ((opcode & 7) != 7) put_reg(ra, u32);
            cycle = 6;
            break;
        }

        // <alu> ra, u8
        case 0x30: case 0x31: case 0x32: case 0x33:
        case 0x34: case 0x35: case 0x36: case 0x37: {

            ra  = fetch_byte();
            u32 = fetch_byte();
            u32 = grp(get_reg(ra), u32, opcode & 7);
            if ((opcode & 7) != 7) put_reg(ra, u32);
            cycle = 3;
            break;
        }

        // <sft> ra, rb
        case 0x38: case 0x39: case 0x3A: case 0x3B: {

            rb = get_reg(fetch_byte());
            ra = fetch_byte();
            put_reg(ra, sft(get_reg(ra), rb, opcode & 3));
            cycle = 4;
            break;
        }

        // <sft> ra, u8
        case 0x3C: case 0x3D: case 0x3E: case 0x3F: {

            ra  = fetch_byte();
            u32 = fetch_byte();
            put_reg(ra, sft(get_reg(ra), u32, opcode & 3));
            cycle = 4;
            break;
        }

        // MUL ra, rb
        case 0x40: {

            rb  = fetch_byte();
            ra  = fetch_byte();
            rc  = (get_reg(ra) * get_reg(rb));
            put_reg(ra, rc & 0xFFFFFFFF);

            zf = ((rc & 0xFFFFFFFF) == 0) ? 1 : 0;
            sf =  (rc & 0x80000000) ? 1 : 0;
            of = (rc & ~0xFFFFFFFF) ? 1 : 0;
            break;
        }
    }

    tstates += cycle;
    ip &= 0xfffff;

    return cycle;
}
