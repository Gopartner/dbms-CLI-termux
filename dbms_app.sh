#!/bin/bash

# Path ke perintah mariadb di Termux
MYSQL_COMMAND="/data/data/com.termux/files/usr/bin/mariadb"

# Konfigurasi database
DB_USER="root"
DB_PASSWORD="your_current_password"  # Ganti dengan kata sandi database Anda

# Fungsi untuk menampilkan daftar basis data yang ada
show_databases() {
    echo "Daftar Basis Data yang Tersedia:"
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;"
}

# Fungsi untuk membuat basis data baru
create_database() {
    echo "Masukkan nama basis data baru:"
    read DB_NAME
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
    echo "Basis data '$DB_NAME' berhasil dibuat."
}

# Fungsi untuk menghapus basis data
drop_database() {
    echo "Daftar Basis Data yang Tersedia:"
    show_databases
    echo "Masukkan nama basis data yang akan dihapus:"
    read DB_NAME
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $DB_NAME;"
    echo "Basis data '$DB_NAME' berhasil dihapus."
}

# Fungsi untuk menampilkan daftar tabel dalam sebuah basis data
show_tables() {
    echo "Masukkan nama basis data:"
    read DB_NAME
    echo "Daftar Tabel dalam Basis Data '$DB_NAME':"
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "USE $DB_NAME; SHOW TABLES;"
}

# Fungsi untuk membuat tabel baru dalam sebuah basis data
create_table() {
    echo "Masukkan nama basis data untuk membuat tabel:"
    read DB_NAME
    echo "Masukkan nama tabel baru:"
    read TABLE_NAME

    # Menampilkan contoh definisi kolom untuk membuat tabel
    echo "Contoh definisi kolom:"
    echo "1. id INT PRIMARY KEY"
    echo "2. name VARCHAR(255)"
    echo "3. age INT"
    echo "4. address TEXT"
    
    echo "Masukkan definisi kolom (pisahkan dengan koma, contoh: id INT PRIMARY KEY, name VARCHAR(255), age INT):"
    read COLUMN_DEFINITION
    
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "USE $DB_NAME; CREATE TABLE IF NOT EXISTS $TABLE_NAME ($COLUMN_DEFINITION);"
    echo "Tabel '$TABLE_NAME' berhasil dibuat di basis data '$DB_NAME'."
}

# Fungsi untuk menghapus tabel dalam sebuah basis data
drop_table() {
    echo "Masukkan nama basis data:"
    read DB_NAME
    echo "Masukkan nama tabel yang akan dihapus:"
    read TABLE_NAME
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "USE $DB_NAME; DROP TABLE IF EXISTS $TABLE_NAME;"
    echo "Tabel '$TABLE_NAME' berhasil dihapus dari basis data '$DB_NAME'."
}

# Fungsi untuk mengubah kata sandi pengguna 'root'
change_root_password() {
    echo "Masukkan kata sandi baru untuk pengguna 'root':"
    read -s NEW_PASSWORD  # -s untuk menyembunyikan input (tidak ditampilkan)
    
    # Mengubah kata sandi menggunakan perintah mariadb
    $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD -e "ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$NEW_PASSWORD';"
    
    # Memperbarui variabel DB_PASSWORD dengan kata sandi baru
    DB_PASSWORD="$NEW_PASSWORD"
    
    echo "Kata sandi pengguna 'root' berhasil diubah."
}

# Fungsi untuk melakukan login
login() {
    while true
    do
        echo "Masukkan nama pengguna (username):"
        read USERNAME
        echo "Masukkan kata sandi (password):"
        read -s PASSWORD
        
        # Verifikasi nama pengguna dan kata sandi menggunakan perintah SQL untuk memeriksa keberadaan pengguna di basis data MariaDB
        LOGIN_RESULT=$(echo "SELECT User FROM mysql.user WHERE User='$USERNAME' AND Password=PASSWORD('$PASSWORD');" | $MYSQL_COMMAND -u $DB_USER -p$DB_PASSWORD --skip-column-names)
        
        if [[ "$LOGIN_RESULT" == "$USERNAME" ]]; then
            echo "Login berhasil sebagai '$USERNAME'."
            echo
            break  # Keluar dari loop jika login berhasil
        else
            echo "Login gagal. Nama pengguna atau kata sandi salah."
            echo "Coba lagi? (y/n):"
            read TRY_AGAIN
            if [[ "$TRY_AGAIN" != "y" ]]; then
                exit 1  # Keluar dari skrip jika pengguna tidak ingin mencoba lagi
            fi
        fi
    done
}

# Login sebelum masuk ke menu utama
login

# Menu utama
while true
do
    echo "Program Manajemen Database MariaDB"
    echo "=================================="
    echo "1. Tampilkan Daftar Basis Data"
    echo "2. Buat Basis Data Baru"
    echo "3. Hapus Basis Data"
    echo "4. Tampilkan Daftar Tabel dalam Basis Data"
    echo "5. Buat Tabel Baru dalam Basis Data"
    echo "6. Hapus Tabel dalam Basis Data"
    echo "7. Ganti Kata Sandi Pengguna 'root'"
    echo "8. Keluar"

    read -p "Pilih tindakan (1-8): " choice

    case $choice in
        1) show_databases ;;
        2) create_database ;;
        3) drop_database ;;
        4) show_tables ;;
        5) create_table ;;
        6) drop_table ;;
        7) change_root_password ;;
        8) echo "Terima kasih telah menggunakan program ini. Selamat tinggal!"; break ;;
        *) echo "Pilihan tidak valid. Silakan coba lagi." ;;
    esac

    echo
done
