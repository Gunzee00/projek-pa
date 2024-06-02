<?php

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
        $userId = auth()->id();
    
        $pesananPembeli = Pesanan::select('id_pesanan', 'user_id_pembeli', 'user_id_penjual', 'status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'penjual', 'nomor_telepon_penjual', 'alamat_penjual')
            ->where('user_id_pembeli', $userId)
            ->get();
    
        // Mengubah path gambar menjadi URL yang dapat diakses
        foreach ($pesananPembeli as $item) {
            $item->gambar = asset($item->gambar);
        }
    
        return response()->json($pesananPembeli, 200);
    }
    

    //menampilkan pesanan ke penjual
    public function pesananPenjual(Request $request)
    {
        $userId = auth()->id();
    
        $pesananMasuk = Pesanan::select('id_pesanan', 'user_id_pembeli', 'user_id_penjual', 'status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'pembeli', 'nomor_telepon_pembeli', 'alamat_pembeli')
            ->where('user_id_penjual', $userId)
            ->get();
    
        // Mengubah path gambar menjadi URL yang dapat diakses
        foreach ($pesananMasuk as $item) {
            $item->gambar = asset($item->gambar);
        }
    
        return response()->json($pesananMasuk, 200);
    }
    
    // Fungsi untuk membuat pesanan dari keranjang
    public function buatPesananDariKeranjang(Request $request)
{
    $userId = auth()->id();

    $keranjang = Keranjang::where('user_id', $userId)->get();

    if ($keranjang->isEmpty()) {
        return response()->json(['message' => 'Keranjang kosong. Tidak ada pesanan yang dibuat.'], 404);
    }

    foreach ($keranjang as $item) {
        $idPenjual = $item->produk->id_pembuat;
        $penjual = User::find($idPenjual);
        $pembeli = User::find($userId);

        $pesanan = Pesanan::create([
            'user_id_pembeli' => $userId,
            'nomor_telepon_pembeli' => $pembeli->nomor_telepon,
            'nomor_telepon_penjual' => $penjual->nomor_telepon,
            'alamat_penjual' => $penjual->alamat,
            'alamat_pembeli' => $pembeli->alamat,
            'user_id_penjual' => $idPenjual,
            'status' => 1,
            'id_produk' => $item->id_produk,
            'jumlah' => $item->jumlah,
            'total_harga' => $item->total_harga,
            'nama_produk' => $item->produk->nama_produk,
            'satuan' => $item->produk->satuan,
            'harga' => $item->produk->harga,
            'gambar' => $item->produk->gambar,
            'penjual' => $penjual->username,
            'pembeli' => $pembeli->username,
        ]);

        $item->produk->decrement('stok', $item->jumlah);
        $item->delete();
    }

    return response()->json(['message' => 'Pesanan berhasil dibuat dari keranjang.'], 201);
}

    public function buatPesananLangsung(Request $request)
{
    $userId = auth()->id();

    $validator = Validator::make($request->all(), [
        'id_produk' => 'required|exists:produk,id_produk',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 400);
    }

    $produk = Produk::find($request->id_produk);

    if (!$produk) {
        return response()->json(['message' => 'Produk tidak ditemukan'], 404);
    }

    $jumlahPemesanan = $produk->minimal_pemesanan;

    $penjual = User::find($produk->id_pembuat);
    $pembeli = User::find($userId);

    $pesanan = Pesanan::create([
        'user_id_pembeli' => $userId,
        'nomor_telepon_pembeli' => $pembeli->nomor_telepon,
        'nomor_telepon_penjual' => $penjual->nomor_telepon,
        'alamat_penjual' => $penjual->alamat,
        'alamat_pembeli' => $pembeli->alamat,
        'user_id_penjual' => $produk->id_pembuat,
        'status' => 1,
        'id_produk' => $produk->id_produk,
        'jumlah' => $jumlahPemesanan,
        'total_harga' => $produk->harga * $jumlahPemesanan,
        'nama_produk' => $produk->nama_produk,
        'satuan' => $produk->satuan,
        'harga' => $produk->harga,
        'gambar' => $produk->gambar,
        'penjual' => $penjual->username,
        'pembeli' => $pembeli->username,
    ]);

    $produk->decrement('stok', $jumlahPemesanan);

    return response()->json(['message' => 'Pesanan berhasil dibuat', 'data' => $pesanan], 201);
}



    //membatalkan pesanan

    public function batalkanPesanan(Request $request, $id_pesanan)
    {
        $userId = auth()->id();
    
        $pesanan = Pesanan::where('id_pesanan', $id_pesanan)
                            ->where('user_id_pembeli', $userId)
                            ->where('status', 1) // Pesanan hanya bisa dibatalkan jika statusnya masih 1 (belum diproses)
                            ->first();
    
        if (!$pesanan) {
            return response()->json(['message' => 'Pesanan tidak ditemukan atau tidak dapat dibatalkan'], 404);
        }
    
        // Perbarui status pesanan menjadi 2 (dibatalkan)
        $pesanan->status = 2;
        $pesanan->save();
    
        // Periksa apakah produk ditemukan sebelum memanggil metode increment
        $produk = Produk::find($pesanan->id_produk);
        if (!$produk) {
            return response()->json(['message' => 'Produk tidak ditemukan'], 404);
        }
    
        // Kembalikan stok produk
        $produk->increment('stok', $pesanan->jumlah);
    
        return response()->json(['message' => 'Pesanan berhasil dibatalkan'], 200);
    }
    
 
// membatalkan pesanan oleh pembeli

public function konfirmasiPesanan(Request $request, $id_pesanan)
{
    $userId = auth()->id();

    $pesanan = Pesanan::where('id_pesanan', $id_pesanan)
                        ->where('user_id_penjual', $userId)
                        ->where('status', 1) // Pesanan hanya bisa dikonfirmasi jika statusnya masih 1 (belum diproses)
                        ->first();

    if (!$pesanan) {
        return response()->json(['message' => 'Pesanan tidak ditemukan atau tidak dapat dikonfirmasi'], 404);
    }

    // Perbarui status pesanan menjadi 3 (diterima oleh penjual)
    $pesanan->status = 3;
    $pesanan->save();

    return response()->json(['message' => 'Pesanan berhasil dikonfirmasi'], 200);
}


public function tolakPesanan(Request $request, $id)
{
    // Mengecek apakah pengguna telah terautentikasi
    if (!Auth::check()) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $userId = Auth::id();

    $pesanan = Pesanan::findOrFail($id);

    // Periksa apakah pengguna yang menolak pesanan adalah penjual dari pesanan tersebut
    if ($pesanan->user_id_penjual !== $userId) {
        return response()->json(['message' => 'Anda tidak memiliki izin untuk menolak pesanan ini.'], 403);
    }

    // Periksa apakah pesanan sudah dikonfirmasi atau dibatalkan sebelumnya
    if ($pesanan->status == 2 || $pesanan->status == 3) {
        return response()->json(['message' => 'Pesanan tidak dapat ditolak karena sudah dibatalkan atau dikonfirmasi sebelumnya.'], 400);
    }

    // Ubah status pesanan menjadi 0 (ditolak)
    $pesanan->status = 4;
    $pesanan->save();

    // Mengembalikan stok produk yang diambil oleh pesanan yang ditolak
    $produk = Produk::find($pesanan->id_produk);
    $produk->increment('stok', $pesanan->jumlah);

    return response()->json(['message' => 'Pesanan berhasil ditolak.'], 200);
}

public function batalkanPesananSetelahKonfirmasi(Request $request, $id)
{
    // Mengecek apakah pengguna telah terautentikasi
    if (!Auth::check()) {
        return response()->json(['message' => 'Unauthorized'], 401);
    }

    $userId = Auth::id();

    $pesanan = Pesanan::findOrFail($id);

    

    // Batalkan pesanan
    $pesanan->status = 5;
    $pesanan->save();

    // Mengembalikan stok produk yang diambil oleh pesanan yang dibatalkan
    $produk = Produk::find($pesanan->id_produk);
    $produk->increment('stok', $pesanan->jumlah);

    return response()->json(['message' => 'Pesanan berhasil dibatalkan.'], 200);
}

//detail pesanan pembeli
// Fungsi untuk mendapatkan detail pesanan pembeli
public function detailPesananPembeli(Request $request, $id_pesanan)
{
    $userId = auth()->id();

    $pesanan = Pesanan::select('id_pesanan','status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'penjual')
                        ->where('id_pesanan', $id_pesanan)
                        ->where('user_id_pembeli', $userId)
                        ->first();

    if (!$pesanan) {
        return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
    }

    return response()->json($pesanan, 200);
}
//detail pesanan penjual
// Fungsi untuk mendapatkan detail pesanan penjual
public function detailPesananPenjual(Request $request, $id_pesanan)
{
    $userId = auth()->id();

    $pesanan = Pesanan::select('id_pesanan','status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'pembeli')
                        ->where('id_pesanan', $id_pesanan)
                        ->where('user_id_penjual', $userId)
                        ->first();

    if (!$pesanan) {
        return response()->json(['message' => 'Pesanan tidak ditemukan'], 404);
    }

    return response()->json($pesanan, 200);
}

    public function countPesananMasuk(Request $request)
        {
            // Memastikan pengguna terautentikasi
            if (!Auth::check()) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $userId = Auth::id();
            
            $jumlahPesananMasuk = Pesanan::where('status', 1)
                                        ->where('user_id_penjual', $userId)
                                        ->count();

            return response()->json(['jumlah_pesanan_masuk' => $jumlahPesananMasuk], 200);
        }

        public function countPesananDikonfirmasi(Request $request)
        {
            // Memastikan pengguna terautentikasi
            if (!Auth::check()) {
                return response()->json(['message' => 'Unauthorized'], 401);
            }

            $userId = Auth::id();

            $jumlahPesananDikonfirmasi = Pesanan::where('status', 3)
                                                ->where('user_id_penjual', $userId)
                                                ->count();

            return response()->json(['jumlah_pesanan_dikonfirmasi' => $jumlahPesananDikonfirmasi], 200);
        }


}
