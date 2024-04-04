<?php

use App\Http\Controllers\BerandaAdminController;
use App\Http\Controllers\BerandaPolisiController;
use App\Http\Controllers\BerandaSuperAdminController;
use App\Http\Controllers\Dinas\SuperAdmin\LaporanMasyarakatController;
use App\Http\Controllers\Polisi\LaporanMasyarakatController as PolisiLaporanMasyarakatController;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Auth;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/


Route::prefix('superadmin')->middleware(['auth', 'auth.superadmin'])->group(function () {
    //ini route khusus untuk Super Super Admin
    Route::get('beranda', [BerandaSuperAdminController::class, 'index'])->name('superadmin.beranda');
    Route::get('chat', [BerandaSuperAdminController::class, 'chat'])->name('superadmin.chat');
    Route::resource('dinas/superadmin/laporan-masyarakat', LaporanMasyarakatController::class);
    Route::post('/laporan-masyarakat/{id}/proses', [LaporanMasyarakatController::class, 'prosesLaporan'])->name('laporan-masyarakat.proses');
});


Route::prefix('admin')->middleware(['auth', 'auth.admin'])->group(function () {
    Route::get('beranda', [BerandaAdminController::class, 'index'])->name('admin.beranda');
});

Route::prefix('pengacara')->middleware(['auth', 'auth.pengacara'])->group(function () {
    //ini route khusus untuk Pengacara
    
});

Route::prefix('polisi')->middleware(['auth', 'auth.polisi'])->group(function () {
    //ini route khusus untuk Polisi
    Route::get('beranda', [BerandaPolisiController::class, 'index'])->name('polisi.beranda');
    Route::resource('polisi/laporan-masyarakat', PolisiLaporanMasyarakatController::class);
    Route::post('polisi/laporan-masyarakat/{id}/proses', [PolisiLaporanMasyarakatController::class, 'prosesLaporan'])->name('polisi-laporan-masyarakat.proses');
});

Route::get('logout', function () {
    Auth::logout();
});


Route::get('/', function () {
    return view('welcome');
});

Auth::routes();

Route::get('/home', [App\Http\Controllers\HomeController::class, 'index'])->name('home');
