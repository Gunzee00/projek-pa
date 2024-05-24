<?php

namespace App\Http\Controllers;

use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator; 

class ProdukController extends Controller
{
    //MENAMPILKAN SAAT LOGIN
 public function index()
    {
          $userId = auth()->user()->id;
         $produks = Produk::where('id_pembuat', $userId)->get();
          return response()->json(['produk' => $produks]);
        }
       
    public function showAll(Request $request)
{
    // Mengambil parameter query pencarian
    $query = $request->input('q');

    // Memulai query untuk mengambil semua produk
    $produkQuery = Produk::query();

    // Jika ada parameter pencarian, tambahkan kondisi pencarian ke query
    if ($query) {
        $produkQuery->where('nama_produk', 'LIKE', '%' . $query . '%')
                    ->orWhere('lokasi_produk', 'LIKE', '%' . $query . '%');
    }

    // Eksekusi query dan ambil hasilnya
    $produks = $produkQuery->get(['id_produk', 'id_pembuat', 'nama_produk', 'lokasi_produk', 'harga', 'gambar', 'deskripsi', 'satuan', 'minimal_pemesanan', 'stok','nama_penjual','nomor_penjual']);

    // Memberikan respons dalam bentuk JSON dengan data produk
    return response()->json(['produk' => $produks], 200);
}

    

    public function store(Request $request)
{
    $userId = auth()->user()->id;
    $validator = Validator::make($request->all(), [
        'nama_produk' => 'required',
        'harga' => 'required',
        'gambar' => 'required',
        'deskripsi' => 'required',
        'satuan' => 'required',
        'lokasi_produk' => 'required',
        'minimal_pemesanan' => 'required|numeric',
        'stok' => 'required|numeric',
    ]); 

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 400);
    }

    // Mendapatkan nama penjual
    $namaPenjual = auth()->user()->nama_lengkap;
    // Mendapatkan nomor telepon penjual
    $nomorPenjual = auth()->user()->nomor_telepon;

    $formData = $request->all();
    $formData['id_pembuat'] = $userId;
    $formData['nama_penjual'] = $namaPenjual; // Menambahkan nama penjual ke dalam data
    $formData['nomor_penjual'] = $nomorPenjual; // Menambahkan nomor telepon penjual ke dalam data

    // Mengecek apakah jumlah yang diminta memenuhi persyaratan minimal pemesanan
    if ($formData['minimal_pemesanan'] > 0 && $formData['minimal_pemesanan'] > $formData['stok']) {
        return response()->json(['message' => 'Jumlah minimal pemesanan tidak boleh melebihi stok yang tersedia.'], 400);
    }

    $form = Produk::create($formData);

    return response()->json(['message' => 'Form created successfully', 'data' => $form], 201);
}

    //delete product
    
    public function delete($id)
{
    $produk = Produk::find($id);

    if (!$produk) {
        return response()->json(['message' => 'Produk not found'], 404);
    }

    $produk->delete();

    return response()->json(['message' => 'Produk deleted successfully'], 200);
}

//UPDATE BARANG

// public function update(Request $request, $id)
// {
//     $userId = auth()->user()->id;
//     $produk = Produk::find($id);

//     if (!$produk) {
//         return response()->json(['message' => 'Produk not found'], 404);
//     }

//     $validator = Validator::make($request->all(), [
//         'nama_produk' => 'required',
//         'harga' => 'required',
//         'gambar' => 'required',
//         'deskripsi' => 'required',
//         'satuan' => 'required',
//         'lokasi_produk' => 'required',
//         'minimal_pemesanan' => 'required|numeric',
//         'stok' => 'required|numeric',
//     ]);

//     if ($validator->fails()) {
//         return response()->json(['errors' => $validator->errors()], 400);
//     }

//     $formData = $request->all();
//     $formData['id_pembuat'] = $userId;

//     $produk->update($formData);

//     return response()->json(['message' => 'Produk updated successfully', 'data' => $produk], 200);
// }

public function update(Request $request, $id)
{
    $userId = auth()->user()->id;
    $produk = Produk::find($id);

    if (!$produk) {
        return response()->json(['message' => 'Produk not found'], 404);
    }

    // Tambahkan validasi jika perlu

    $produk->update($request->all());

    return response()->json(['message' => 'Produk updated successfully', 'data' => $produk], 200);
}
    
     
}
