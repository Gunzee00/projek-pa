<?php

use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Auth\RegisterController;
 
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BarangController;
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

// Route::get('/barang', [BarangController::class, 'read']);



Route::group(['middleware' => ['auth:sanctum']], function () {
    Route::get('/user/profile', [LoginController::class, 'index']);
    Route::post('/logout', [LoginController::class, 'logout']);
    Route::get('/barang', [BarangController::class, 'index']);
    //menampilkan semua data
    Route::get('/barang-pembeli', [BarangController::class, 'indexpembeli']);
    Route::post('/create-barang', [BarangController::class, 'store']);
    Route::delete('/delete-barang/{id}', [BarangController::class, 'delete']);
    Route::put('/update-barang/{id}', [BarangController::class, 'update']);
});
