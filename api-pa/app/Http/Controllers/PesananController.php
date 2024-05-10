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

        $pesananPembeli = Pesanan::select('status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'penjual', 'pembeli')
            ->where('user_id_pembeli', $userId)
            ->get();

        return response()->json($pesananPembeli, 200);
    }

    //menampilkan pesanan ke penjual
    public function pesananPenjual(Request $request)
    {
        $userId = auth()->id();

        $pesananMasuk = Pesanan::select('status', 'jumlah', 'nama_produk', 'satuan', 'harga', 'gambar', 'total_harga', 'pembeli')
            ->where('user_id_penjual', $userId)
            ->get();

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
                'user_id_penjual' => $idPenjual,
                'status' => 1,
                'id_produk' => $item->id_produk,
                'jumlah' => $item->jumlah,
                'total_harga' => $item->total_harga,
                'nama_produk' => $item->produk->nama_produk,
                'satuan' => $item->produk->satuan,
                'harga' => $item->produk->harga,
                'gambar' => $item->produk->gambar,
                'penjual' => $penjual->username, // Menggunakan username penjual
                'pembeli' => $pembeli->username, // Menggunakan username pembeli
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
}
