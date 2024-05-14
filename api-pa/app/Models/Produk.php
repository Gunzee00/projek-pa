<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;

    protected $table = 'produk';

    protected $primaryKey = 'id_produk';
   
    protected $fillable = [
        'id_pembuat',
        'nama_produk',
        'harga',
        'gambar',
        'deskripsi',
        'lokasi_produk',
        'satuan',
        'minimal_pemesanan',
        'stok',
        'nama_penjual', // Tambahkan kolom 'nama_penjual' ke $fillable
        'nomor_penjual'
    ];

    // Relasi dengan model User (Pembuat Barang)
    public function pembuat()
    {
        return $this->belongsTo(User::class, 'id_pembuat');
    }

    // Tambahkan method untuk mendapatkan nama penjual
    public function getNamaPenjualAttribute()
    {
        return $this->pembuat->nama_lengkap;
    }
}
