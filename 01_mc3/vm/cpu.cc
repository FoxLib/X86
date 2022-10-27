// Чтение байта или слова из памяти
unsigned short App::read(int A, int b = 0) {

    if (b) {
        return mem[A & 0xFFFF] + mem[(A + 1) & 0xFFFF]*256;
    } else {
        return mem[A & 0xFFFF];
    }
}

// Считывание байта из потока
unsigned char App::fetch() {

    unsigned char b = mem[ip];
    ip = (ip + 1) & 0xFFFF;
    return b;
}

// Считывание слова из потока
unsigned short App::fetch_word() {

    int a = fetch();
    int b = fetch();
    return a + b*256;
}

// Получение значения регистра
unsigned short App::get_reg(int n, int bit) {

    // Определить EA
    switch (n & 7) {

        case 0: return bit ? ax : ax & 255;
        case 1: return bit ? cx : cx & 255;
        case 2: return bit ? dx : dx & 255;
        case 3: return bit ? bx : bx & 255;
        case 4: return bit ? sp : (ax >> 8) & 255;
        case 5: return bit ? bp : (cx >> 8) & 255;
        case 6: return bit ? si : (dx >> 8) & 255;
        case 7: return bit ? di : (bx >> 8) & 255;
    }

    return 0;
}

// Считывание операндов и ModRM
void App::fetch_modrm() {

    modrm   = fetch();
    mod     = (modrm >> 6) & 3;
    mod_reg = (modrm >> 3) & 7;
    mod_rm  = (modrm & 7);

    switch (mod_rm) {

        case 0: ea = bx + si; break;
        case 1: ea = bx + di; break;
        case 2: ea = bp + si; break;
        case 3: ea = bp + di; break;
        case 4: ea = si; break;
        case 5: ea = di; break;
        case 6: ea = mod ? bp : fetch_word(); break;
        case 7: ea = bx; break;
    }

    op1 = get_reg(dir ? mod_reg : mod_rm,  size);
    op2 = get_reg(dir ? mod_rm  : mod_reg, size);

    // Добавление +8/+16
    if (mod == 1) {
        ea += (signed char) fetch();
    } else if (mod == 2) {
        ea += fetch_word();
    }

    ea &= 0xFFFF;

    int m3 = (mod == 3);

    // Чтение из памяти по EA
    if (dir) {
        op1 =      get_reg(mod_reg, size);
        op2 = m3 ? get_reg(mod_rm,  size) : read(ea, size);
    } else {
        op1 = m3 ? get_reg(mod_rm,  size) : read(ea, size);
        op2 =      get_reg(mod_reg, size);
    }
}

// Групповые инструкции АЛУ
unsigned short App::group_alu(int id, unsigned short op1, unsigned short op2) {

    unsigned short R;

    switch (id & 7) {

        case 0: R = op1 + op2; break;
        case 1: R = op1 | op2; break;
        case 2: R = op1 + op2 + (flags & 1); break;
        case 3: R = op1 - op2 - (flags & 1); break;
        case 4: R = op1 & op2; break;
        case 5:
        case 7: R = op1 - op2; break;
        case 6: R = op1 ^ op2; break;
    }

    return size ? R & 0xFFFF : R & 0xFF;
}

void App::step() {

    opcode = fetch();

    size =  opcode & 1;
    dir  = (opcode >> 1) & 1;

    switch (opcode) {

        // Базовое АЛУ с ModRM байтом
        case 0x00: case 0x01: case 0x02: case 0x03: // ADD
        case 0x08: case 0x09: case 0x0A: case 0x0B: // OR
        case 0x10: case 0x11: case 0x12: case 0x13: // ADC
        case 0x18: case 0x19: case 0x1A: case 0x1B: // SBB
        case 0x20: case 0x21: case 0x22: case 0x23: // AND
        case 0x28: case 0x29: case 0x2A: case 0x2B: // SUB
        case 0x30: case 0x31: case 0x32: case 0x33: // XOR
        case 0x38: case 0x39: case 0x3A: case 0x3B: // CMP

            fetch_modrm();
            group_alu((opcode >> 3) & 7, op1, op2);
            break;
    }

}
