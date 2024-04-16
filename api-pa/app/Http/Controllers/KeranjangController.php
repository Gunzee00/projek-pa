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
    // public function index()
    //     {
    //         $userId = auth()->user()->id;
    //         $keranjang = Keranjang::where('user_id', $userId)->get();
    //         if ($keranjang->isEmpty()) {
    //             return response()->json(['message' => 'Isi keranjang kosong.'], 404);
    //         }
    //         return response()->json($keranjang, 200);       
    //      }

//tampilkan isi keranjang user
    public function index()
        {
            $userId = auth()->user()->id;
$keranjang = Keranjang::where('user_id', $userId)->select( 'nama_produk','jumlah', 'satuan', 'total_harga')->get();
if ($keranjang->isEmpty()) {
    return response()->json(['message' => 'Isi keranjang kosong.'], 404);
}
return response()->json($keranjang, 200); 
         }

        //  public function tambahKeranjang(Request $request)
        //  {
        //      // Validasi request
        //      $request->validate([
        //          'id_produk' => 'required|exists:produk,id_produk', // Menggunakan kolom yang benar, yaitu id_produk
        //          'jumlah' => 'required|integer|min:1',
        //      ]);
         
        //      // Mendapatkan data produk dari request
        //      $produkId = $request->id_produk;
        //      $jumlah = $request->jumlah;
             
        //      // Mengambil data produk dari database
        //      $produk = Produk::findOrFail($produkId);
        //      $hargaProduk = $produk->harga;
        //      $namaProduk = $produk->nama_produk;
        //      $satuan = $produk->satuan;
        //      $gambar = $produk->gambar;
         
        //      // Memeriksa apakah jumlah pesanan memenuhi jumlah minimal pemesanan
        //      if ($jumlah < $produk->minimal_pemesanan) {
        //          return response()->json(['message' => 'Jumlah pesanan kurang dari jumlah minimal pemesanan'], 400);
        //      }
         
        //      // Menghitung total harga berdasarkan harga produk dan jumlah
        //      $totalHarga = $hargaProduk * $jumlah;
         
        //      // Mendapatkan ID pengguna yang login menggunakan token
        //      $userId = Auth::id();
         
        //      // Menambahkan produk ke keranjang
        //      Keranjang::create([
        //          'user_id' => $userId,
        //          'id_produk' => $produkId,
        //          'jumlah' => $jumlah,
        //          'nama_produk' => $namaProduk,
        //          'satuan' => $satuan,
        //          'harga' => $hargaProduk,
        //          'gambar' => $gambar,
        //          'total_harga' => $totalHarga,
        //      ]);
         
        //      return response()->json(['message' => 'Produk berhasil ditambahkan ke keranjang.'], 201);
        //  }

         //tambahkan keranjang
        public function tambahKeranjang(Request $request)
{
    // Validasi request
    $request->validate([
        'id_produk' => 'required|exists:produk,id_produk', // Menggunakan kolom yang benar, yaitu id_produk
        'jumlah' => 'required|integer|min:1',
    ]);

    // Mendapatkan data produk dari request
    $produkId = $request->id_produk;
    $jumlah = $request->jumlah;

    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = Auth::id();

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
        ]);
    }

    return response()->json(['message' => 'Produk berhasil ditambahkan ke keranjang.'], 201);
}



public function hapusKeranjang(Request $request)
{
    // Validasi request
        $request->validate([
            'id_keranjang' => 'required|exists:keranjang,id', // Validasi berdasarkan ID keranjang
        ]);

    // Mendapatkan ID keranjang dari request
    $keranjangId = $request->id_keranjang;

    // Mendapatkan ID pengguna yang login menggunakan token
    $userId = Auth::id();

    // Cari keranjang untuk pengguna yang login berdasarkan ID keranjang
    $keranjang = Keranjang::where('user_id', $userId)->where('id', $keranjangId)->first();

    // Jika keranjang tidak ditemukan, kirimkan respons error
    if (!$keranjang) {
        return response()->json(['message' => 'Keranjang tidak ditemukan.'], 404);
    }

    // Hapus keranjang
    $keranjang->delete();

    return response()->json(['message' => 'Produk berhasil dihapus dari keranjang.'], 200);
}

}
