<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PelaporanKeDinas extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'judul_pelaporan',
        'isi_laporan',
        'visibility',
        'file_path',
        'gambar',
        'pengaduan',
        'tanggal_kejadian',
        'lokasi_kejadian',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
