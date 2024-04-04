<?php

namespace App\Http\Controllers;

use App\Models\Barang;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator; 

class BarangController extends Controller
{
    //MENAMPILKAN SAAT LOGIN
        public function index()
        {
            $userId = auth()->user()->id;
            $barangs = Barang::where('id_pembuat', $userId)->get();
            return response()->json(['barang' => $barangs]);
        }
    
    //menampilkan semua barang 
    public function indexpembeli()
{
    $barangs = Barang::all();
    return response()->json(['barang' => $barangs]);
}



    // public function index()
    // {
    //     $userId = auth()->user()->id;
    //     $barangs = Barang::where('id_pembuat', $userId)->get();
    //     return response()->json(['barang' => $barangs]);
    // }
    


    public function store(Request $request)
    {
        $userId = auth()->user()->id;
        $validator = Validator::make($request->all(), [
           'nama_barang' => 'required',
            'harga' => 'required',
            'gambar' => 'required',
            'deskripsi' => 'required',
            'satuan' => 'required',
            'minimal_pemesanan' => 'required|numeric',
            'stok' => 'required|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        $formData = $request->all();
        $formData['id_pembuat'] = $userId;
        $form = Barang::create($formData);

        $this->response['success'] = true;
        $this->response['message'] = 'Form created successfully';
        $this->response['data'] = $form;

        return response()->json($this->response, 201);
    }
    
    public function delete($id)
{
    $barang = Barang::find($id);

    if (!$barang) {
        return response()->json(['message' => 'Produk not found'], 404);
    }

    $barang->delete();

    return response()->json(['message' => 'Produk deleted successfully'], 200);
}

//UPDATE BARANG

public function update(Request $request, $id)
{
    $userId = auth()->user()->id;
    $barang = Barang::find($id);

    if (!$barang) {
        return response()->json(['message' => 'Produk not found'], 404);
    }

    $validator = Validator::make($request->all(), [
        'nama_barang' => 'required',
        'harga' => 'required',
        'gambar' => 'required',
        'deskripsi' => 'required',
        'satuan' => 'required',
        'minimal_pemesanan' => 'required|numeric',
        'stok' => 'required|numeric',
    ]);

    if ($validator->fails()) {
        return response()->json(['errors' => $validator->errors()], 400);
    }

    $formData = $request->all();
    $formData['id_pembuat'] = $userId;

    $barang->update($formData);

    return response()->json(['message' => 'Produk updated successfully', 'data' => $barang], 200);
}





    // public function store(Request $request)
    // {
    //     $userId = auth()->user()->id;
    //     // Validasi input
    //     $request->validate([
    //         'nama_barang' => 'required',
    //         'harga' => 'required',
    //         'gambar' => 'required',
    //         'deskripsi' => 'required',
    //         'satuan' => 'required',
    //         'minimal_pemesanan' => 'required|numeric',
    //         'stok' => 'required|numeric',
    //         // Anda mungkin perlu menambahkan validasi lain sesuai kebutuhan
    //     ]);
    //     return $request;

    //     if (!Auth::check()) {
    //         return response()->json(['message' => 'Unauthorized'], 401);
    //     }

    //     // Membuat barang baru
    //     $barang = new Barang();
    //     $barang->nama_barang = $request->nama_barang;
    //     $barang->harga = $request->harga;
    //     $barang->gambar = $request->gambar;
    //     $barang->deskripsi = $request->deskripsi;
    //     $barang->satuan = $request->satuan;
    //     $barang->minimal_pemesanan = $request->minimal_pemesanan;
    //     $barang->stok = $request->stok;

    //     // Set id_pembuat dari pembeli yang sedang login
    //     $barang->id_pembuat = $userId; // Mengambil ID pembeli yang sedang login

    //     // Simpan barang ke database
    //     $barang->save();

    //     // Memberi respons bahwa barang berhasil dibuat
    //     return response()->json(['message' => 'Barang berhasil dibuat', 'barang' => $barang], 201);
    // }

     
}
