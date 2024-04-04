<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PelaporanMasyarakat extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'judul_pelaporan',
        'isi_laporan',
        'pengaduan',
        'tanggal_kejadian',
        'lokasi_kejadian',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
