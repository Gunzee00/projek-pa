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
    // Fungsi untuk menampilkan pesanan pengguna
    public function index()
    {
        // Mendapatkan ID pengguna yang login menggunakan token
        $userId = Auth::id();

        // Mengambil pesanan pengguna berdasarkan ID pengguna
        $pesanan = Pesanan::where('user_id', $userId)->get();

        // Mengecek apakah pesanan ditemukan
        if ($pesanan->isEmpty()) {
            return response()->json(['message' => 'Tidak ada pesanan untuk pengguna ini.'], 404);
        }

        return response()->json($pesanan, 200);
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
        // Membuat pesanan
        $pesanan = Pesanan::create([
            'user_id' => $userId,
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
