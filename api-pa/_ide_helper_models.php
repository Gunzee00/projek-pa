<?php

// @formatter:off
/**
 * A helper file for your Eloquent Models
 * Copy the phpDocs from this file to the correct Model,
 * And remove them from this file, to prevent double declarations.
 *
 * @author Barry vd. Heuvel <barryvdh@gmail.com>
 */


namespace App\Models{
/**
 * App\Models\PelaporanKeDinas
 *
 * @property int $id
 * @property int $user_id
 * @property string $judul_pelaporan
 * @property string $isi_laporan
 * @property string $visibility
 * @property string|null $file_path
 * @property string|null $gambar
 * @property string $tanggal_kejadian
 * @property string $lokasi_kejadian
 * @property string $status
 * @property string|null $catatan_petugas
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read \App\Models\User $user
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas newModelQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas newQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas query()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereCatatanPetugas($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereCreatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereFilePath($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereGambar($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereIsiLaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereJudulPelaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereLokasiKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereStatus($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereTanggalKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereUpdatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereUserId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKeDinas whereVisibility($value)
 */
	class PelaporanKeDinas extends \Eloquent {}
}

namespace App\Models{
/**
 * App\Models\PelaporanKePolisi
 *
 * @property int $id
 * @property int $user_id
 * @property string $judul_pelaporan
 * @property string $isi_laporan
 * @property string $visibility
 * @property string|null $file_path
 * @property string|null $gambar
 * @property string $tanggal_kejadian
 * @property string $lokasi_kejadian
 * @property string $status
 * @property string|null $catatan_petugas
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read \App\Models\User $user
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi newModelQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi newQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi query()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereCatatanPetugas($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereCreatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereFilePath($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereGambar($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereIsiLaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereJudulPelaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereLokasiKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereStatus($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereTanggalKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereUpdatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereUserId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanKePolisi whereVisibility($value)
 */
	class PelaporanKePolisi extends \Eloquent {}
}

namespace App\Models{
/**
 * App\Models\PelaporanMasyarakat
 *
 * @property int $id
 * @property int $user_id
 * @property string $judul_pelaporan
 * @property string $isi_laporan
 * @property string $visibility
 * @property string|null $file_path
 * @property string|null $gambar
 * @property string $pengaduan
 * @property string $tanggal_kejadian
 * @property string $lokasi_kejadian
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read \App\Models\User $user
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat newModelQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat newQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat query()
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereCreatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereFilePath($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereGambar($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereIsiLaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereJudulPelaporan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereLokasiKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat wherePengaduan($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereTanggalKejadian($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereUpdatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereUserId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|PelaporanMasyarakat whereVisibility($value)
 */
	class PelaporanMasyarakat extends \Eloquent {}
}

namespace App\Models{
/**
 * App\Models\User
 *
 * @property int $id
 * @property string $akses
 * @property string $full_name
 * @property string $username
 * @property string|null $foto_profil
 * @property string $nohp
 * @property string $nohp_verified_at
 * @property string $email
 * @property \Illuminate\Support\Carbon|null $email_verified_at
 * @property mixed $password
 * @property string|null $remember_token
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * @property-read \Illuminate\Notifications\DatabaseNotificationCollection<int, \Illuminate\Notifications\DatabaseNotification> $notifications
 * @property-read int|null $notifications_count
 * @property-read \Illuminate\Database\Eloquent\Collection<int, \App\Models\PelaporanKeDinas> $pelaporanMasyarakatKeDinas
 * @property-read int|null $pelaporan_masyarakat_ke_dinas_count
 * @property-read \Illuminate\Database\Eloquent\Collection<int, \App\Models\PelaporanKePolisi> $pelaporanMasyarakatKePolisi
 * @property-read int|null $pelaporan_masyarakat_ke_polisi_count
 * @property-read \Illuminate\Database\Eloquent\Collection<int, \Laravel\Sanctum\PersonalAccessToken> $tokens
 * @property-read int|null $tokens_count
 * @method static \Database\Factories\UserFactory factory($count = null, $state = [])
 * @method static \Illuminate\Database\Eloquent\Builder|User newModelQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|User newQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|User query()
 * @method static \Illuminate\Database\Eloquent\Builder|User whereAkses($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereCreatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereEmail($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereEmailVerifiedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereFotoProfil($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereFullName($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereId($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereNohp($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereNohpVerifiedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User wherePassword($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereRememberToken($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereUpdatedAt($value)
 * @method static \Illuminate\Database\Eloquent\Builder|User whereUsername($value)
 */
	class User extends \Eloquent {}
}

namespace App\Models{
/**
 * App\Models\c
 *
 * @method static \Illuminate\Database\Eloquent\Builder|c newModelQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|c newQuery()
 * @method static \Illuminate\Database\Eloquent\Builder|c query()
 */
	class c extends \Eloquent {}
}

