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

        foreach ($produks as $produk) {
            $produk->gambar = asset($produk->gambar); // Mengubah path gambar menjadi URL yang dapat diakses
        }

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
        $produks = $produkQuery->get(['id_produk', 'id_pembuat', 'nama_produk', 'lokasi_produk', 'harga', 'gambar', 'deskripsi', 'satuan', 'minimal_pemesanan', 'stok', 'nama_penjual', 'nomor_penjual']);

        // Mengubah path gambar menjadi URL yang dapat diakses
        foreach ($produks as $produk) {
            $produk->gambar = asset($produk->gambar);
        }

        // Memberikan respons dalam bentuk JSON dengan data produk
        return response()->json(['produk' => $produks], 200);
    }
    
    public function update(Request $request, $id)
    {
        $userId = auth()->user()->id;
    
        // Mencari produk berdasarkan ID
        $produk = Produk::find($id);
    
        // Memastikan produk ada dan dibuat oleh pengguna yang login
        if (!$produk || $produk->id_pembuat != $userId) {
            return response()->json(['message' => 'Produk tidak ditemukan atau Anda tidak memiliki izin untuk mengedit produk ini.'], 404);
        }
    
        // Validasi input
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'sometimes|required',
            'harga' => 'sometimes|required|numeric',
            'gambar' => 'sometimes|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'deskripsi' => 'sometimes|required',
            'satuan' => 'sometimes|required',
            'lokasi_produk' => 'sometimes|required',
            'minimal_pemesanan' => 'sometimes|required|numeric',
            'stok' => 'sometimes|required|numeric',
        ]);
    
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }
    
        // Handle the image upload if a new image is provided
        if ($request->hasFile('gambar')) {
            $image = $request->file('gambar');
            $imageName = uniqid() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('images'), $imageName);
            $imagePath = 'images/' . $imageName; // Update the image path to be stored in the database
            $produk->gambar = $imagePath;
        }
    
        // Update the product fields
        $fields = ['nama_produk', 'harga', 'deskripsi', 'satuan', 'lokasi_produk', 'minimal_pemesanan', 'stok'];
        foreach ($fields as $field) {
            if ($request->has($field)) {
                $produk->$field = $request->input($field);
            }
        }
    
        // Mengecek apakah jumlah yang diminta memenuhi persyaratan minimal pemesanan
        if ($request->has('minimal_pemesanan') && $request->input('minimal_pemesanan') > $produk->stok) {
            return response()->json(['message' => 'Jumlah minimal pemesanan tidak boleh melebihi stok yang tersedia.'], 400);
        }
    
        // Menyimpan perubahan
        $produk->save();
    
        // Mengubah path gambar menjadi URL yang dapat diakses
        if ($request->hasFile('gambar')) {
            $produk->gambar = asset($produk->gambar);
        }
    
        return response()->json(['message' => 'Produk berhasil diperbarui', 'data' => $produk], 200);
    }
    

public function store(Request $request)
    {
        $userId = auth()->user()->id;

        // Validasi input
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'required',
            'harga' => 'required|numeric',
            'gambar' => 'required|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'deskripsi' => 'required',
            'satuan' => 'required',
            'lokasi_produk' => 'required',
            'minimal_pemesanan' => 'required|numeric',
            'stok' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        // Handle the image upload
        if ($request->hasFile('gambar')) {
            $image = $request->file('gambar');
            $imageName = uniqid() . '.' . $image->getClientOriginalExtension();
            $image->move(public_path('images'), $imageName);
            $imagePath = 'images/' . $imageName; // Format yang diinginkan untuk disimpan di database
        } else {
            return response()->json(['message' => 'Gambar produk diperlukan'], 400);
        }

        // Mendapatkan nama dan nomor telepon penjual
        $namaPenjual = auth()->user()->nama_lengkap;
        $nomorPenjual = auth()->user()->nomor_telepon;

        $formData = $request->all();
        $formData['id_pembuat'] = $userId;
        $formData['nama_penjual'] = $namaPenjual; // Menambahkan nama penjual ke dalam data
        $formData['nomor_penjual'] = $nomorPenjual; // Menambahkan nomor telepon penjual ke dalam data
        $formData['gambar'] = $imagePath; // Store the image path in the database

        // Mengecek apakah jumlah yang diminta memenuhi persyaratan minimal pemesanan
        if ($formData['minimal_pemesanan'] > 0 && $formData['minimal_pemesanan'] > $formData['stok']) {
            return response()->json(['message' => 'Jumlah minimal pemesanan tidak boleh melebihi stok yang tersedia.'], 400);
        }

        // Membuat produk baru
        $form = Produk::create($formData);

        // Mengubah path gambar menjadi URL yang dapat diakses
        $form->gambar = asset($form->gambar);

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
    
 


    
}
