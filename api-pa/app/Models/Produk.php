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
        'satuan',
        'minimal_pemesanan',
        'stok',
    ];

    // Relasi dengan model User (Pembuat Barang)
    public function pembuat()
    {
        return $this->belongsTo(User::class, 'id_pembuat');
    }
}
