<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\User;
use App\Models\Produk;
class Keranjang extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $table = 'keranjang'; // Menetapkan nama tabel ke 'keranjang'

    protected $fillable = [
        'user_id',
        'id_produk',
        'jumlah',
        'nama_produk',
        'satuan',
        'harga',
        'gambar',
        'total_harga',
        'penjual'
    ];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array
     */
    protected $casts = [
        'total_harga' => 'decimal:2',
    ];

    /**
     * Relationship with User model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relationship with Produk model.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function produk()
    {
        return $this->belongsTo(Produk::class, 'id_produk'); // Menyesuaikan kunci luar dengan kolom 'id_produk'
    }
}