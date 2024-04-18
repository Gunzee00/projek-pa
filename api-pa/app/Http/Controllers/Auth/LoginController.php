<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Providers\RouteServiceProvider;
use Exception;
use Illuminate\Foundation\Auth\AuthenticatesUsers;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class LoginController extends Controller
{
    /*
    |--------------------------------------------------------------------------
    | Login Controller
    |--------------------------------------------------------------------------
    |
    | This controller handles authenticating users for the application and
    | redirecting them to your home screen. The controller uses a trait
    | to conveniently provide its functionality to your applications.
    |
    */

    use AuthenticatesUsers;

    /**
     * Where to redirect users after login.
     *
     * @var string
     */
    protected $redirectTo = RouteServiceProvider::HOME;
    
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    // public function __construct()
    // {
    //     $this->middleware('guest')->except('logout');
    // }

    // public function __construct()
    // {
    //     $this->middleware('auth:sanctum'); // Protecting routes with Sanctum middleware
    // }

    protected function loginApi(Request $request)
    {
        $loginData = $request->validate([
            'username' => 'required',
            'password' => 'required'
        ]); 

        if (Auth::attempt($loginData)) {
            $token = Auth::user()->createToken('authToken')->plainTextToken;
            return response()->json([
                'message' => 'Login Success',
                'data' => Auth::user(),
                'token' => $token,
            ], 200);
        }
        return response()->json([
            'message' => 'Failed Login',
        ], 401);
    }

    private $response = [
        'success' => 0,
        'message' => null,
        'data' => null,
    ];

    public function index()
    {
        $user = Auth::user();
        $this->response['success'] = 1;
        $this->response['message'] = 'success';
        $this->response['data'] = $user;
        return response()->json($this->response, 200);
    }

    public function updateUser(Request $request)
    {
        try {
            $request->validate([
                'username' => 'required|unique:users,username,' . Auth::id(),
                'nama_lengkap' => 'required',
                'nomor_telepon' => 'required|unique:users,nomor_telepon,' . Auth::id(),
                'alamat' => 'required',
                'password' => 'required'
            ]);
    
            $user = Auth::user();
            $user->username = $request->input('username');
            $user->nama_lengkap = $request->input('nama_lengkap');
            $user->nomor_telepon = $request->input('nomor_telepon');
            $user->alamat = $request->input('alamat');
            $user->password = bcrypt($request->input('password'));
            $user->save();
    
            return response()->json([
                'message' => 'Profil sudah diubah',
                'data' => $user
            ]);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => 'Validation error',
                'errors' => $e->validator->errors()
            ], 422);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Failed to update user information',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    

}
