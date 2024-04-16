<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Produk;
class Pesanan extends Model
{
    use HasFactory;

    protected $table = 'pesanan'; // Nama tabel dalam database

    protected $primaryKey = 'id_pesanan'; // Nama kolom primary key

    protected $fillable = [ // Kolom-kolom yang dapat diisi secara massal
        'user_id',
        'status',
        'id_produk',
        'jumlah',
        'total_harga',
        'nama_produk', // Tambahan kolom dari join tabel produk
        'satuan', // Tambahan kolom dari join tabel produk
        'harga', // Tambahan kolom dari join tabel produk
        'gambar', // Tambahan kolom dari join tabel produk
    ];

    // Relasi dengan model User (pengguna)
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    // Relasi dengan model Produk
    public function produk()
    {
        return $this->belongsTo(Produk::class, 'id_produk');
    }
}
