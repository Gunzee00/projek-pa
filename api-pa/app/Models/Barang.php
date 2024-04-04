<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;


class Barang extends Model
{
    use HasFactory;

    protected $table = 'barang';

    protected $primaryKey = 'id_barang';

    protected $fillable = [
        'id_pembuat',
        'nama_barang',
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
