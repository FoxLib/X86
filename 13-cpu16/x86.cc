#include "app.cc"

class X86 : public App {

protected:

    int         tstates;
    uint16_t    ip = 0;
    uint16_t    ax, bx, cx, dx, sp, bp, si, di;
    uint16_t    flags = 0;
    uint16_t    op1, op2, ea, size, dir;
    uint8_t     opcode;
    uint8_t     modrm;
    int         run = 0;

    // Дизассемблер
    int  reg, mod, rm;
    char tmps[256];
    char dis_row[256];
    int  eip;
    char dis_rg[32];        /* Rm-часть Modrm */
    char dis_rm[32];        /* Rm-часть Modrm */
    char dis_px[32];        /* Префикс */

public:

    // Наследуем конструктор и переопределяем его
    X86(int argc, char** argv) :
    App(argc, argv, "X86 Microemulator") {

        int i;
        memory = (uint8_t*) malloc(65536);

        // Очистить память
        for (i = 0x0000; i <= 0xFFFF; i++) {
            memory[i] = 0;
        }

        // Заполнить тестовыми данными видеодисплей
        for (i = 0xB800; i < 0xC800; i += 2) {
            memory[i  ] = (i >> 1) & 255;
            memory[i+1] = 0x07;
        }

        // Разбор параметров тиктока
        for (i = 1; i < argc; i++) {

            FILE* fp = fopen(argv[i], "rb");
            if (fp) {
                fread(memory, 1, 65536, fp);
                fclose(fp);
            } else {
                printf("Эй! Да нету же такого файла %s, гадство!\n", argv[i]);
                exit(1);
            }
        }
    }
    
    // Дизассемблер
    // -----------------------------------------------------------------
    int readb(int address);
    int fetchb();
    int fetchw();
    int fetchd();
    int disas_modrm(int reg32, int mem32);
    int disassemble(int address);
    int debugout(int address);
    // -----------------------------------------------------------------

    void process() {

        int kb = get_next_key(); 
        
        if (run) {

            if (kb == key_F10) {
                
                debugout(ip);
                run = 0;
                
            } else {

                int states = 0;
                do { states += step(); } while (states < 10000); // потом настроить на 25 мгц        
                display_update();
            }
                        
        } else {
            
            switch (kb) {

                case key_F7: {
                
                    step();
                    debugout(0); // поправить 
                    break;
                }

                case key_F9: {
                    
                    run = 1;
                    break;
                }
            }
        }        
    }

    // -----------------------------------------------------------------
    
    // Обращения к памяти
    uint8_t read(int address) {
        return memory[address & 0xFFFF];
    }

    // Сохранить байт в памяти
    void write(int address, uint8_t data) {
        
        memory[address & 0xFFFF] = data;
        if (address > 0xB800) need_update = 1;
    }
    
    uint8_t fetch8() {
        return read(ip++);
    }
    
    uint16_t fetch16() {

        uint8_t a = fetch8();
        uint8_t b = fetch8();
        return (b<<8) | a;
    }

    // Чтение signed-значения
    int fetchsign() {

        uint8_t a = fetch8();
        return (a & 0x80) ? a - 256 : a;
    }

    // Либо 8 либо 16 бит, зависит от size
    inline uint16_t fetch() {
        return size ? fetch16() : fetch8();
    }

    // Чтение регистра n (size=8/16 bit)
    uint16_t get_reg(int n) {

        switch (n & 7) {

            case 0: return size ? ax : ax & 0xff;
            case 1: return size ? cx : cx & 0xff;
            case 2: return size ? dx : dx & 0xff;
            case 3: return size ? bx : bx & 0xff;
            case 4: return size ? sp : (ax >> 8) & 0xff;
            case 5: return size ? bp : (cx >> 8) & 0xff;
            case 6: return size ? si : (dx >> 8) & 0xff;
            case 7: return size ? di : (bx >> 8) & 0xff;
        }

        return 0;
    }

    // Запись регистра
    void put_reg(int n, uint16_t data) {

        tstates++;

        switch (n & 7) {

            case 0: if (size) ax = data; else ax = (ax & 0xFF00) | (data & 0xFF); break;
            case 1: if (size) cx = data; else cx = (cx & 0xFF00) | (data & 0xFF); break;
            case 2: if (size) dx = data; else dx = (dx & 0xFF00) | (data & 0xFF); break;
            case 3: if (size) bx = data; else bx = (bx & 0xFF00) | (data & 0xFF); break;
            case 4: if (size) sp = data; else ax = (ax & 0x00FF) | (data << 8); break;
            case 5: if (size) bp = data; else cx = (cx & 0x00FF) | (data << 8); break;
            case 6: if (size) si = data; else dx = (dx & 0x00FF) | (data << 8); break;
            case 7: if (size) di = data; else bx = (bx & 0x00FF) | (data << 8); break;
        }
    }

    // Чтение байта modrm
    void fetch_modrm() {

        tstates++;
        modrm = fetch8();

        // Выбор эффективного адреса
        switch (modrm & 7) {

            case 0: ea = bx + si; break;
            case 1: ea = bx + di; break;
            case 2: ea = bp + si; break;
            case 3: ea = bp + di; break;
            case 4: ea = si; break;
            case 5: ea = di; break;
            case 6: ea = modrm & 0xc0 ? bp : fetch16(); break;
            case 7: ea = bx; break;
        }

        // Дочитать displacement
        switch (modrm & 0xc0) {

            case 0x00: if ((modrm & 7) == 0x06) tstates += 2; break;
            case 0x40: ea = ea + fetchsign(); tstates += 1; break;
            case 0x80: ea = ea + fetch16();   tstates += 2; break;
        }

        // Чтение из памяти и регистра
        if ((modrm & 0xC0) == 0xC0) {

            op1 = get_reg(dir ? modrm >> 3 : modrm);
            op2 = get_reg(dir ? modrm : modrm >> 3); 
        }
        // Чтение из регистра и регистра
        else {

            uint16_t op = read(ea);
            if (size) op += (256*read(ea + 1));

            op1 = dir ? get_reg(modrm >> 3) : op;
            op2 = dir ? op : get_reg(modrm >> 3);

            tstates += (1 + size);
        }
    }

    // Сохранить в регистр или память
    void put(uint16_t data) {
        
        if ((modrm & 0xC0) == 0xC0 || dir) {

            put_reg(dir ? modrm >> 3 : modrm, data);

        } else {

            tstates += 3;
            write(ea, data);
            if (size) {
                write(ea + 1, data >> 8);
                tstates++;
            }
        }
    }

    // -----------------------------------------------------------------
    // BA98 76543210
    // ODIT SZ-A-P-C
    // -----------------------------------------------------------------

    // CARRY FLAG
    void set_cf(uint16_t r) {

        if (r & (size ? 0x10000 : 0x100))
             flags |=  0x01;
        else flags &= ~0x01;
    }

    // SIGN FLAG
    void set_sf(uint16_t r) {

        if (r & (size ? 0x8000 : 0x80))
             flags |=  0x80;
        else flags &= ~0x80;
    }

    // ZERO FLAG
    void set_zf(uint16_t r) {

        if (r & (size ? 0xFFFF : 0xFF))
             flags &= ~0x40; 
        else flags |=  0x40;
    }

    // AUX FLAG
    void set_af(uint8_t a) {

        if (a & 0x10)
             flags |=  0x10;
        else flags &= ~0x10;
    }

    // PARITY FLAG
    void set_pf(uint8_t a) {

        a = (a >> 4) & a;
        a = (a >> 2) & a;
        a = (a >> 1) & a;

        if (a & 1)
             flags &= ~0x04;
        else flags |=  0x04;
    }

    // OVERFLOW FLAG
    void set_of(uint16_t a) {

        if (a & (size ? 0x8000 : 0x80))
             flags |=  0x800;
        else flags &= ~0x800;
    }

    // -----------------------------------------------------------------
    uint16_t add(uint16_t a, uint16_t b) {

        int c = a + b;
        set_sf(c);
        set_zf(c);
        set_af(a ^ b ^ c);
        set_pf(c);
        set_cf(c);
        set_of((~(a ^ b)) & (a ^ c));
        return c;
    }

    uint16_t adc(uint16_t a, uint16_t b) {

        int c = a + b + (flags & 1);
        set_sf(c);
        set_zf(c);
        set_af(a ^ b ^ c);
        set_pf(c);
        set_cf(c);
        set_of((~(a ^ b)) & (a ^ c));
        return c;
    }

    uint16_t sub(uint16_t a, uint16_t b) {

        int c = a - b; 
        set_sf(c);
        set_zf(c);
        set_af(a ^ b ^ c);
        set_pf(c);
        set_cf(c);
        set_of((a ^ b) & (a ^ c));
        return c;
    }

    uint16_t sbb(uint16_t a, uint16_t b) {

        int c = a - b - (flags & 1);
        set_sf(c);
        set_zf(c);
        set_af(a ^ b ^ c);
        set_pf(c);
        set_cf(c);
        set_of((a ^ b) & (a ^ c));
        return c;
    }

    uint16_t _or(uint16_t a, uint16_t b) {

        int c = a | b;
        set_sf(c);
        set_zf(c);
        set_af(0);
        set_pf(c);
        set_cf(0);
        set_of(0);
        return c;
    }

    uint16_t _and(uint16_t a, uint16_t b) {

        int c = a & b;
        set_sf(c);
        set_zf(c);
        set_af(0);
        set_pf(c);
        set_cf(0);
        set_of(0);
        return c;
    }

    uint16_t _xor(uint16_t a, uint16_t b) {

        int c = a ^ b;
        set_sf(c);
        set_zf(c);
        set_af(0);
        set_pf(c);
        set_cf(0);
        set_of(0);
        return c;
    }

    uint16_t group_alu(int n, uint16_t a, uint16_t b) {

        switch (n & 7) {

            case 0: return  add(a, b); 
            case 1: return _or (a, b); 
            case 2: return  adc(a, b); 
            case 3: return  sbb(a, b); 
            case 4: return _and(a, b); 
            case 5: return  sub(a, b); 
            case 6: return _xor(a, b); 
            case 7: return  sub(a, b); 
        }

        return 0;
    }
    // -----------------------------------------------------------------

    int step() {

        int op;

        tstates = 2;
        opcode  = fetch8();
        size    = !!(opcode & 1);
        dir     = !!(opcode & 2);

        switch (opcode) {

            // Базовое АЛУ
            case 0x00: case 0x01: case 0x02: case 0x03:     // ADD
            case 0x08: case 0x09: case 0x0A: case 0x0B:     // OR
            case 0x10: case 0x11: case 0x12: case 0x13:     // ADC
            case 0x18: case 0x19: case 0x1A: case 0x1B:     // SBB
            case 0x20: case 0x21: case 0x22: case 0x23:     // AND
            case 0x28: case 0x29: case 0x2A: case 0x2B:     // SUB
            case 0x30: case 0x31: case 0x32: case 0x33: {   // XOR
            
                fetch_modrm();
                put(group_alu(opcode >> 3, op1, op2));
                break;
            }
            case 0x38: case 0x39: case 0x3A: case 0x3B: {   // CMP

                fetch_modrm();
                sub(op1, op2);
                break;
            }

            // Базовое АЛУ с Immediate
            case 0x04: case 0x05:   // ADD
            case 0x0C: case 0x0D:   // OR
            case 0x14: case 0x15:   // ADC
            case 0x1C: case 0x1D:   // SBB
            case 0x24: case 0x25:   // AND
            case 0x2C: case 0x2D:   // SUB
            case 0x34: case 0x35: { // XOR

                put_reg(0, group_alu(opcode >> 3, get_reg(0), fetch()));
                break;
            }            
            case 0x3C: case 0x3D: { // CMP

                sub(get_reg(0), fetch());
                break;
            }

            // MOV rm|r
            case 0x88: case 0x89: case 0x8A: case 0x8B: {
                
                fetch_modrm();
                put(op2);
                break;
            }

            // MOV a,[m16]
            case 0xA0: case 0xA1: { 
                
                op = fetch16();
                put_reg(0, read(op) + size*256*read(op+1));
                tstates += (2 + 1 + size);
                break;
            }

            // MOV [m16],a
            case 0xA2: case 0xA3: {

                op = fetch16();
                write(op, get_reg(0));
                if (size) write(op + 1, get_reg(0) >> 8);
                tstates += (2 + 2 + size);
                break;
            }

            // MOV r, i
            case 0xB0: case 0xB1: case 0xB2: case 0xB3:
            case 0xB4: case 0xB5: case 0xB6: case 0xB7:
            case 0xB8: case 0xB9: case 0xBA: case 0xBB:
            case 0xBC: case 0xBD: case 0xBE: case 0xBF: { 

                size = !!(opcode & 0x08);
                put_reg(opcode & 7, fetch());
                tstates += (1 + size);
                break;
            }
            case 0xEB: { // JMP short 

                op = fetchsign();
                ip = ip + op;
                break;
            }
        }

        return tstates;
    }
};
