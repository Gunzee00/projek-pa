<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\KeranjangController;
use App\Http\Controllers\ProdukController;

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::post('user/login', [LoginController::class, 'loginApi']);
Route::post('user/register', [RegisterController::class, 'registerApi']);
// Route::resource('pelaporan-masyarakat-ke-dinas', PelaporanKeDinasController::class)->middleware('auth:sanctum');
// Route::resource('pelaporan-masyarakat-ke-polisi', PelaporanKePolisiController::class)->middleware('auth:sanctum');
// Route::middleware('auth:sanctum')->get('/user/profile', function (Request $request) {
//     return $request->user();
// });
//

Route::get('/produk/all', [ProdukController::class, 'showAll']);


Route::group(['middleware' => ['auth:sanctum']], function () {
    // Rute untuk mengambil profil pengguna
    Route::get('/user/profile', [LoginController::class, 'index']);

    // Rute untuk mengedit profil pengguna
    
    Route::put('/user/update', [LoginController::class, 'updateUser']);

    //-------------------------------Produk-----------------------------//
    // Route::post('/logout', [LoginController::class, 'logout']);
    //show produk berdasarkan pembuat
    Route::get('/produk', [ProdukController::class, 'index']);
    //create produk
     Route::post('/create-produk', [ProdukController::class, 'store']);
     //hapus produk
    Route::delete('/delete-produk/{id}', [ProdukController::class, 'delete']);
    //update produk
    Route::put('/update-produk/{id}', [ProdukController::class, 'update']);


    //-------------------------------Keranjang-----------------------------//
    //view keranjang
    Route::get('/keranjang', [KeranjangController::class, 'index']);
    //tambah ke keranjang
    Route::post('/keranjang/tambah-keranjang', [KeranjangController::class, 'tambahKeranjang']);
    //hapus isi keranjang
    Route::delete('/keranjang/hapus-keranjang', [KeranjangController::class, 'hapusKeranjang']);
    

    //-------------------------------Pesanan-----------------------------//
     //pesanan
     Route::get('/pesanan', [PesananController::class, 'index']);
     //menampikan pesanan pembeli
     Route::get('/pesanan/pembeli', [PesananController::class, 'pesananPembeli']);
     //menampikan pesanan pembeli
     Route::get('/pesanan/penjual', [PesananController::class, 'pesananPenjual']);
     //membuat pesanan
     Route::post('/pesanan/buat-pesanan', [PesananController::class, 'buatPesananDariKeranjang']);

});
