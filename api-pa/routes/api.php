<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
use App\Http\Controllers\PesananController;
use App\Http\Controllers\KeranjangController;
use App\Http\Controllers\ProdukController;
use App\Http\Controllers\ProfileController;

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
    // Rute untuk menampilkan profil pengguna
    Route::get('/user/profile', [ProfileController::class, 'showUserInfo']);

    // Rute untuk mengedit profil pengguna
    
    Route::put('/user/update', [ProfileController::class, 'updateUser']);

    //user logout
    Route::post('/user/logout', [LoginController::class, 'logoutApi']);


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
    //update isi keranjang
    Route::put('/keranjang/update-keranjang', [KeranjangController::class, 'updateJumlahKeranjang']);
    //detail produk di keranjang
    Route::get('/keranjang/detail', [KeranjangController::class, 'detailKeranjang']);

   

    //-------------------------------Pesanan-----------------------------//
     //pesanan
     Route::get('/pesanan', [PesananController::class, 'index']);
     //menampikan pesanan pembeli
     Route::get('/pesanan/pembeli', [PesananController::class, 'pesananPembeli']);
     //menampikan pesanan pembeli
     Route::get('/pesanan/penjual', [PesananController::class, 'pesananPenjual']);
     Route::post('/pesanan/buat-pesanan-langsung', [PesananController::class, 'buatPesananLangsung']);
     //membuat pesanan dari keranjang
     Route::post('/pesanan/buat-pesanan', [PesananController::class, 'buatPesananDariKeranjang']);
     //penjual konfirmasi pesanan
     

});
