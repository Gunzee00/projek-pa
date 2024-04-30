<?php

namespace App\Http\Controllers;

namespace App\Http\Controllers;
use App\Models\Keranjang;
use App\Models\Produk;
use App\Models\Pesanan;
use App\Models\User;
 
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator; 

class PesananController extends Controller
{
     

//menampilkan pesanan yang dibuat pembeli
public function pesananPembeli(Request $request)
{
    // Jika pengguna tidak login, middleware 'auth:api' akan mengembalikan respon 401 Unauthorized
    // Jika pengguna telah login, middleware akan menambahkan informasi pengguna ke dalam request
    // sehingga kita dapat mengakses ID pengguna yang login dengan auth()->id()
    $userId = auth()->id();

    // Mengambil pesanan yang dimiliki oleh pengguna yang login
    $pesananPembeli = Pesanan::select('status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga')
        ->where('user_id_pembeli', $userId)
        ->get();

    // Mengembalikan data pesanan dalam bentuk JSON
    return response()->json($pesananPembeli, 200);
}

//menampilkan pesanan ke penjual
public function pesananPenjual(Request $request)
    {
        // Mendapatkan ID pengguna penjual yang login menggunakan token
        $userId = auth()->id();

        // Mengambil pesanan yang masuk untuk penjual yang login
        $pesananMasuk = Pesanan::select('status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga')
            ->where('user_id_penjual', $userId)
            ->get();

        // Mengembalikan data pesanan dalam bentuk JSON
        return response()->json($pesananMasuk, 200);
    }

   // Fungsi untuk membuat pesanan dari keranjang
   public function buatPesananDariKeranjang(Request $request)
{
    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = auth()->id();

    // Mengambil semua barang dari keranjang pengguna
    $keranjang = Keranjang::where('user_id', $userId)->get();

    // Jika keranjang kosong, kembalikan pesan kesalahan
    if ($keranjang->isEmpty()) {
        return response()->json(['message' => 'Keranjang kosong. Tidak ada pesanan yang dibuat.'], 404);
    }

    // Membuat pesanan dari setiap item di keranjang
    foreach ($keranjang as $item) {
        // Mendapatkan ID pengguna penjual (pemilik produk)
        $idPenjual = $item->produk->id_pembuat;

        // Membuat pesanan
        $pesanan = Pesanan::create([
            'user_id_pembeli' => $userId,
            'user_id_penjual' => $idPenjual, // Menggunakan ID penjual dari produk
            'status' => 1, // Status pesanan "1" menunjukkan bahwa pesanan baru dibuat
            'id_produk' => $item->id_produk,
            'jumlah' => $item->jumlah,
            'total_harga' => $item->total_harga,
            // Mengisi kolom tambahan dari tabel produk
            'nama_produk' => $item->produk->nama_produk,
            'satuan' => $item->produk->satuan,
            'harga' => $item->produk->harga,
            'gambar' => $item->produk->gambar,
        ]);

        // Mengurangi stok produk berdasarkan jumlah yang dipesan
        $item->produk->decrement('stok', $item->jumlah);

        // Menghapus item dari keranjang setelah dibuat menjadi pesanan
        $item->delete();
    }

    return response()->json(['message' => 'Pesanan berhasil dibuat dari keranjang.'], 201);
}


}
