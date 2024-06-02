<?php

namespace App\Http\Controllers;
use App\Models\Keranjang;
use App\Models\Produk;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator; 
class KeranjangController extends Controller
{
  

//tampilkan isi keranjang user
public function index()
{
    $userId = auth()->user()->id;
    $keranjang = Keranjang::where('user_id', $userId)
                    ->select('id_produk', 'nama_produk', 'gambar', 'jumlah', 'satuan', 'total_harga', 'penjual')
                    ->get();

    if ($keranjang->isEmpty()) {
        return response()->json(['message' => 'Isi keranjang kosong.'], 404);
    }
    foreach ($keranjang as $item) {
        $item->gambar = asset($item->gambar); // Mengubah path gambar menjadi URL yang dapat diakses
    }

    return response()->json($keranjang, 200);
}
 
         //tambahkan keranjang
         public function tambahKeranjang(Request $request)
         {
             // Validasi request
             $request->validate([
                 'id_produk' => 'required|exists:produk,id_produk',
                 'jumlah' => 'required|integer|min:1',
             ]);
         
             // Mendapatkan data produk dari request
             $produkId = $request->id_produk;
             $jumlah = $request->jumlah;
         
             // Mendapatkan ID pengguna yang login menggunakan token
             $userId = Auth::id();
         
             if (!$userId) {
                // Jika pengguna tidak terautentikasi (tidak memiliki ID pengguna yang valid)
                return response()->json(['message' => 'Anda harus login untuk menambahkan produk ke keranjang.'], 401);
            }
             // Cek apakah produk sudah ada dalam keranjang pengguna yang sedang login
             $existingItem = Keranjang::where('user_id', $userId)
                                         ->where('id_produk', $produkId)
                                         ->first();
         
             if ($existingItem) {
                 // Jika sudah ada, perbarui jumlah dan total harga
                 $existingItem->jumlah += $jumlah;
                 $existingItem->total_harga += ($existingItem->harga * $jumlah);
                 $existingItem->save();
             } else {
                 // Jika belum ada, tambahkan produk baru ke keranjang
                 // Mengambil data produk dari database
                 $produk = Produk::findOrFail($produkId);
                 $hargaProduk = $produk->harga;
                 $namaProduk = $produk->nama_produk;
                 $satuan = $produk->satuan;
                 $gambar = $produk->gambar;
                 
                 // Menambahkan nama penjual ke dalam keranjang
                 $penjual = User::find($produk->id_pembuat)->username;
         
                 // Memeriksa apakah jumlah pesanan memenuhi jumlah minimal pemesanan
                 if ($jumlah < $produk->minimal_pemesanan) {
                     return response()->json(['message' => 'Jumlah pesanan kurang dari jumlah minimal pemesanan'], 400);
                 }
         
                 // Menghitung total harga berdasarkan harga produk dan jumlah
                 $totalHarga = $hargaProduk * $jumlah;
         
                 // Menambahkan produk ke keranjang
                 Keranjang::create([
                     'user_id' => $userId,
                     'id_produk' => $produkId,
                     'jumlah' => $jumlah,
                     'nama_produk' => $namaProduk,
                     'satuan' => $satuan,
                     'harga' => $hargaProduk,
                     'gambar' => $gambar,
                     'total_harga' => $totalHarga,
                     'penjual' => $penjual, // Menambahkan nama penjual
                 ]);
             }
         
             return response()->json(['message' => 'Produk berhasil ditambahkan ke keranjang.'], 201);
         }

         public function updateKeranjang(Request $request, $id_produk)
{
    // Validasi request
    $request->validate([
        'jumlah' => 'required|integer|min:1',
    ]);

    // Mendapatkan jumlah baru dari request
    $jumlahBaru = $request->jumlah;

    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = auth()->id();

    // Temukan item keranjang berdasarkan user_id dan id_produk
    $itemKeranjang = Keranjang::where('user_id', $userId)
                               ->where('id_produk', $id_produk)
                               ->first();

    // Jika item keranjang tidak ditemukan, kembalikan respons 404
    if (!$itemKeranjang) {
        return response()->json(['message' => 'Item keranjang tidak ditemukan.'], 404);
    }

    // Mendapatkan data produk dari database
    $produk = Produk::findOrFail($id_produk);

    // Memeriksa apakah jumlah baru memenuhi jumlah minimal pemesanan
    if ($jumlahBaru < $produk->minimal_pemesanan) {
        return response()->json(['message' => 'Jumlah pesanan harus di atas atau sama dengan jumlah minimal pemesanan: ' . $produk->minimal_pemesanan], 400);
    }

    // Perbarui jumlah dan total harga item keranjang
    $itemKeranjang->jumlah = $jumlahBaru;
    $itemKeranjang->total_harga = $produk->harga * $jumlahBaru;
    $itemKeranjang->save();

    return response()->json(['message' => 'Jumlah produk dalam keranjang berhasil diperbarui.'], 200);
}


public function hapusKeranjang(Request $request)
{
    // Validasi request
    $request->validate([
        'id_produk' => 'required|exists:keranjang,id_produk,user_id,' . auth()->id(),
    ]);

    // Mendapatkan ID produk yang akan dihapus dari request
    $produkId = $request->id_produk;

    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = auth()->id();

    // Cari item keranjang yang sesuai dengan pro   dukId dan userId
    $itemKeranjang = Keranjang::where('user_id', $userId)
                               ->where('id_produk', $produkId)
                               ->first();

    // Jika item keranjang ditemukan, hapus
    if ($itemKeranjang) {
        $itemKeranjang->delete();
        return response()->json(['message' => 'Item keranjang berhasil dihapus.'], 200);
    } else {
        return response()->json(['message' => 'Item keranjang tidak ditemukan.'], 404);
    }
}

public function detailKeranjang(Request $request)
{
    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = auth()->id();

    // Mengambil detail keranjang pengguna yang sedang login
    $keranjang = Keranjang::where('user_id', $userId)
                    ->select('id_produk', 'nama_produk', 'jumlah', 'satuan', 'total_harga' )
                    ->get();

    if ($keranjang->isEmpty()) {
        return response()->json(['message' => 'Keranjang kosong.'], 404);
    }

    return response()->json($keranjang, 200);
}


}
