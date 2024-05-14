<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class Pesanan extends Model
{
    use HasFactory;

    protected $table = 'pesanan'; // Nama tabel dalam database

    protected $primaryKey = 'id_pesanan'; // Nama kolom primary key

    protected $fillable = [ // Kolom-kolom yang dapat diisi secara massal
        'user_id_pembeli',
        'user_id_penjual',
        'status',
        'id_produk',
        'jumlah',
        'nama_produk',
        'satuan',
        'harga',
        'gambar',
        'total_harga',
        'penjual',
        'pembeli',
        'nomor_telepon_pembeli',
        'nomor_telepon_penjual',
        'alamat_penjual',
        'alamat_pembeli'
    ];

    // Relasi dengan model User untuk pengguna pembeli
    public function pembeli()
    {
        return $this->belongsTo(User::class, 'user_id_pembeli');
    }

    // Relasi dengan model User untuk pengguna penjual
    public function penjual()
    {
        return $this->belongsTo(User::class, 'user_id_penjual');
    }

    // Relasi dengan model Produk
    public function produk()
    {
        return $this->belongsTo(Produk::class, 'id_produk');
    }

    // Fungsi untuk menampilkan pesanan hanya untuk pembeli tertentu
    public static function pesananPembeli($userId)
    {
        return self::where('user_id_pembeli', $userId)->get();
    }
}
